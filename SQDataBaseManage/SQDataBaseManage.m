//
//  SQDataBaseManage.m
//  SQDataBaseManage
//
//  Created by lhq on 2018/2/26.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import "SQDataBaseManage.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import "HomeCoupon.h"
#import "SQUser.h"

static NSString *kAppInitConfigurationLocalPathName = @"AppInitConfiguration";
static NSString *kReportCouponLocalPathName = @"ReportCoupon";
static NSString *kSearchHistoryLocalPathName = @"search_cache_data";
static NSString *kMarkObjectLocalPathName = @"mark_obj";

@interface SQDataBaseManage ()

@end

@implementation SQDataBaseManage

+ (LKDBHelper *)defaultLKDBHelper {
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [[LKDBHelper alloc] initWithDBName:@"LKDB"];
#if DEBUG
        NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        filePath = [filePath stringByAppendingPathComponent:@"db/LKDB.db"];
        NSLog(@"[ DatabaseHandle ] LKDB path is %@",filePath);
#endif
    });
    return db;
}

/**
 LKDB add，updata，delete，objects
 */
+ (void)addObject:(id)object {
    [SQDataBaseManage addObject:object callback:nil];
}

+ (void)addObject:(id)object callback:(void (^)(BOOL result))callback {
    [[SQDataBaseManage defaultLKDBHelper] insertToDB:object callback:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(result);
            NSLog(@"add object to DB : %@",result ? @"sucess" : @"failed");
        });
    }];
}

+ (void)updataObject:(id)object where:(NSString *)where {
    [SQDataBaseManage updataObject:object where:(NSString *)where callback:nil];
}

+ (void)updataObject:(id)object where:(NSString *)where callback:(void (^)(BOOL result))callback {
    [[SQDataBaseManage defaultLKDBHelper] updateToDB:object where:where callback:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(result);
            NSLog(@"updata object to DB : %@",result ? @"sucess" : @"failed");
        });
    }];
}

+ (void)deleteObject:(id)object {
    [SQDataBaseManage deleteObject:object callback:nil];
}

+ (void)deleteObject:(id)object callback:(void (^)(BOOL result))callback {
    [[SQDataBaseManage defaultLKDBHelper] deleteToDB:object callback:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(result);
            NSLog(@"delete object to DB : %@",result ? @"sucess" : @"failed");
        });
    }];
}

+ (id)objectSingle:(Class)modelClass where:(id)where {
    return [[SQDataBaseManage defaultLKDBHelper] searchSingle:modelClass where:where orderBy:nil];
}

+ (NSArray *)objectsWithModelClass:(Class)modelClass where:(NSString *)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count {
    return [[SQDataBaseManage defaultLKDBHelper] search:modelClass where:where orderBy:orderBy offset:offset count:count];
}

+ (void)objectsWithModelClass:(Class)modelClass where:(NSString *)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count callback:(void (^)(NSMutableArray *array))callback {
    [[SQDataBaseManage defaultLKDBHelper] search:modelClass where:where orderBy:orderBy offset:offset count:count callback:^(NSMutableArray * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(array);
        });
    }];
}

/////////////////////////////////////////////////////////////////////////

/**
数据库具体业务
 */

+ (void)addObject:(id)object whereType:(DBWhereType)whereType {
    [SQDataBaseManage addObject:object whereType:whereType callback:nil];
}

+ (void)addObject:(id)object whereType:(DBWhereType)whereType callback:(void (^)(BOOL result))callback {
    switch (whereType) {
        case DBWhereTypeReceived:
            [SQDataBaseManage saveReceivedCouponToDB:object callBack:callback];
            break;
        case DBWhereTypeHistory:
            [SQDataBaseManage saveHistoryCouponToDB:object callBack:callback];
            break;
        case DBWhereTypeUserInfo:
            [SQDataBaseManage addUserInfo:object callBack:callback];
            break;
        default:
            break;
    }
}

+ (void)deleteObject:(id)object whereType:(DBWhereType)whereType {
    [SQDataBaseManage deleteObject:object whereType:whereType callback:nil];
}

+ (void)deleteObject:(id)object whereType:(DBWhereType)whereType callback:(void (^)(BOOL result))callback {
    switch (whereType) {
        case DBWhereTypeReceived:
            [SQDataBaseManage deleteReceivedCouponFromDB:object callBack:callback];
            break;
        case DBWhereTypeHistory:
            [SQDataBaseManage deleteHistoryCouponFromDB:object callBack:callback];
            break;
        case DBWhereTypeUserInfo:
            [SQDataBaseManage deleteUserInfoCallBack:callback];
            break;
        default:
            break;
    }
}

+ (id)objectSingleWithWhereType:(DBWhereType)whereType {
    id object;
    switch (whereType) {
        case DBWhereTypeUserInfo:
            object = [SQDataBaseManage objectUserInfo];
            break;
        default:
            break;
    }
    return object;
}

+ (NSArray *)objectsWithWhereType:(DBWhereType)whereType page:(NSInteger)page pageSize:(NSInteger)pageSize {
    NSArray *arr = [NSArray array];
    switch (whereType) {
        case DBWhereTypeReceived:
            arr = [SQDataBaseManage loadReceiveCouponListWithPage:page pageSize:pageSize];
            break;
        case DBWhereTypeHistory:
            arr = [SQDataBaseManage loadHistoryCouponListWithPage:page pageSize:pageSize];
            break;
        default:
            break;
    }
    return arr;
}

// history coupon
+ (void)saveHistoryCouponToDB:(HomeCoupon *)coupon callBack:(void(^)(BOOL result))callBack {
    if (![coupon isKindOfClass:[HomeCoupon class]] || coupon.couponId.length <= 0) {
        return;
    }
    
    NSString *where = [NSString stringWithFormat:@"couponId='%@'",coupon.couponId];
    HomeCoupon *oldCoupon = [SQDataBaseManage objectSingle:[HomeCoupon class] where:where];
    
    if (oldCoupon) {
        coupon.couponHasReceive = oldCoupon.couponHasReceive;
        coupon.c_timestamp = oldCoupon.c_timestamp;
    }

    coupon.timestamp = [[NSDate date] timeIntervalSince1970];
    coupon.history = YES;
    
    [SQDataBaseManage addObject:coupon callback:callBack];
}

+ (void)deleteHistoryCouponFromDB:(HomeCoupon *)coupon callBack:(void(^)(BOOL result))callBack {
    NSString *where = [NSString stringWithFormat:@"couponId='%@' And history=1",coupon.couponId];
    HomeCoupon *oldCoupon = [SQDataBaseManage objectSingle:[HomeCoupon class] where:where];
    
    if (!oldCoupon) return;
    
    if (oldCoupon.couponHasReceive) {
        oldCoupon.history = NO;
        [SQDataBaseManage updataObject:oldCoupon where:where callback:callBack];
    }else {
        [SQDataBaseManage deleteObject:coupon callback:callBack];
    }
}

+ (NSArray *)loadHistoryCouponListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    NSString *where = [NSString stringWithFormat:@"history=1"];
    NSArray *coupons = [SQDataBaseManage objectsWithModelClass:[HomeCoupon class] where:where orderBy:@"timestamp desc" offset:page * pageSize count:pageSize];
    return coupons;
}

// received coupon
+ (void)saveReceivedCouponToDB:(HomeCoupon *)coupon callBack:(void(^)(BOOL result))callBack {
    if (![coupon isKindOfClass:[HomeCoupon class]] || coupon.couponId.length <= 0) {
        return;
    }
    NSString *where = [NSString stringWithFormat:@"couponId='%@'",coupon.couponId];
    HomeCoupon *oldCoupon = [SQDataBaseManage objectSingle:[HomeCoupon class] where:where];
    
    if (oldCoupon) {
        coupon.history = oldCoupon.history;
        coupon.timestamp = oldCoupon.timestamp;
    }
    
    coupon.c_timestamp = [[NSDate date] timeIntervalSince1970];
    coupon.couponHasReceive = YES;
    
    [SQDataBaseManage addObject:coupon callback:callBack];
}

+ (void)deleteReceivedCouponFromDB:(HomeCoupon *)coupon callBack:(void(^)(BOOL result))callBack {
    NSString *where = [NSString stringWithFormat:@"couponId='%@' And couponHasReceive=1",coupon.couponId];
    HomeCoupon *oldCoupon = [SQDataBaseManage objectSingle:[HomeCoupon class] where:where];
    
    if (!oldCoupon) return;
    
    if (oldCoupon.history) {
        oldCoupon.couponHasReceive = NO;
        [SQDataBaseManage updataObject:oldCoupon where:where callback:callBack];
    }else {
        [SQDataBaseManage deleteObject:coupon callback:callBack];
    }
}

+ (NSArray *)loadReceiveCouponListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    // 过滤无效过期商品
    if (page == 0) {
        NSString *where = [NSString stringWithFormat:@"couponHasReceive=1"];
        
        NSArray *coupons = [SQDataBaseManage objectsWithModelClass:[HomeCoupon class] where:where orderBy:@"c_timestamp desc" offset:0 count:100];
        
        [coupons enumerateObjectsUsingBlock:^(HomeCoupon * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            long long currentTime = kCFAbsoluteTimeIntervalSince1970 + CFAbsoluteTimeGetCurrent();
            // TO DO  测试数据没有ticket节点
//            long long timeInterval = obj.ticket.expiredTime - currentTime;
//            if (timeInterval <= 0) {
//                [self deleteReceivedCouponFromDB:obj callBack:^(BOOL result) {}];
//            }
            if (!currentTime) {
                obj.couponHasReceive = NO;
                NSString *where = [NSString stringWithFormat:@"couponId='%@'",obj.couponId];
                [SQDataBaseManage updataObject:obj where:where];
            }
        }];
        
    }
    
    NSString *where = [NSString stringWithFormat:@"couponHasReceive=1"];
    NSArray *coupons = [SQDataBaseManage objectsWithModelClass:[HomeCoupon class] where:where orderBy:@"timestamp desc" offset:page * pageSize count:pageSize];
    return coupons;
}

// UserInfo
+ (void)addUserInfo:(id)object callBack:(void(^)(BOOL result))callBack {
    [SQDataBaseManage addObject:object callback:callBack];
}

+ (void)deleteUserInfoCallBack:(void(^)(BOOL result))callBack {
    id object = [SQDataBaseManage objectSingle:[SQUser class] where:@""];
    [SQDataBaseManage deleteObject:object callback:callBack];
}

+ (id)objectUserInfo {
    return [SQDataBaseManage objectSingle:[SQUser class] where:nil];
}

/**
 *其他非数据库的持久化业务
 */
+ (BOOL)saveDataFile:(id)file toFile:(NSString *)filename {
    NSData *_data = nil;
    if ([file isKindOfClass:[NSData class]]) {
        _data = file;
    }else if ([file isKindOfClass:[NSDictionary class]] || [file isKindOfClass:[NSArray class]]) {
        _data = [NSKeyedArchiver archivedDataWithRootObject:file];
    }else if (![file conformsToProtocol:@protocol(NSCoding)]) {
        return NO;
    }
    NSString *filePath = [self basePathWithName:filename];
    
    return [_data writeToFile:filePath atomically:YES];
}

+ (NSData *)readDataWithFileName:(NSString*)filename {
    NSString *filePath = [self basePathWithName:filename];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+ (id)readDataFile:(NSString*)filename {
    NSString *filePath = [self basePathWithName:filename];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!object) {
        object = data;
    }
    return object;
}

+ (NSString *)basePathWithName:(NSString *)filename {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [docPath stringByAppendingPathComponent:filename];
    return filePath;
}

+ (NSString *)localJSFilePath {
    return [self basePathWithName:@"coupon_insertCoupon"];
}

// AppConfiguration
//+ (AppInitConfiguration *)appInitConfiguration {
//    NSDictionary *jsonDic = [self readDataFile:kAppInitConfigurationLocalPathName];
//    if (!jsonDic) {
//        return [AppInitConfiguration new];
//    }
//    return [AppInitConfiguration yy_modelWithJSON:jsonDic];
//}
//
//+ (BOOL)saveAppInitConfiguration:(AppInitConfiguration *)configuration {
//    NSDictionary *jsonDic = [configuration yy_modelToJSONObject];
//    NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:jsonDic];
//    return [self saveDataFile:jsonData toFile:kAppInitConfigurationLocalPathName];
//}

// App cache.
+ (CGFloat)appCacheSize {
    CGFloat kbSize =[[SDImageCache sharedImageCache] getSize];
    kbSize = kbSize/1024;
    
    return kbSize;
}

+ (NSString *)appCacheSizeString {
    CGFloat kbSize =[self appCacheSize]; // kb
    
    NSInteger u = 0;
    for (; kbSize > 1; kbSize = kbSize/1024) {
        u ++;
    }
    kbSize = kbSize *1024;
    u = fmin(4, u);
    NSString *unit = @[@"K", @"M", @"G", @"T"][(int)fmax(u - 1, 0)];
    
    NSString *cacheSizeString = [NSString stringWithFormat:@"%.1f %@",kbSize,unit];
    return cacheSizeString;
}

+ (void)clearAppCacheCompletion:(void(^)(CGFloat leftSize, NSString *leftSizeStr))completion {
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:^{
        if (completion) {
            completion([self appCacheSize],[self appCacheSizeString]);
        }
    }];
}

// Search history
+ (NSArray *)searchHistoryList {
    NSArray *data = [self readDataFile:kSearchHistoryLocalPathName];
    if (!data) {
        data = [NSMutableArray arrayWithCapacity:0];
    }
    return data;
}

+ (BOOL)saveSearchHistoryList:(NSArray *)historys {
    if (historys) {
        return [self saveDataFile:[historys mutableCopy] toFile:kSearchHistoryLocalPathName];
    }
    return NO;
}

+ (BOOL)saveSearchHistory:(NSString *)search {
    if (!search || search.length <= 0) {
        return NO;
    }
    NSMutableArray *data = [[self readDataFile:kSearchHistoryLocalPathName] mutableCopy];
    if (!data) {
        data = [NSMutableArray arrayWithCapacity:0];
    }
    [data addObject:search];
    return [self saveDataFile:data toFile:kSearchHistoryLocalPathName];
}

+ (BOOL)clearAllSearchHistory {
    NSString *searchFilePath = [self basePathWithName:kSearchHistoryLocalPathName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager removeItemAtPath:searchFilePath error:nil];
    return result;
}

+ (BOOL)clearSearchHistory:(NSString *)search {
    if (!search || search.length <= 0) {
        return NO;
    }
    NSMutableArray *data = [[self readDataFile:kSearchHistoryLocalPathName] mutableCopy];
    if (data.count <= 0) {
        return NO;
    }
    [data removeObject:search];
    if (data.count == 0) {
        return [self clearAllSearchHistory];
    }
    return [self saveDataFile:data toFile:kSearchHistoryLocalPathName];
}

+ (void)synchronizeHistoryToServer {}

+ (void)synchronizeHistoryToServer:(NSString *)searchText{}

// Report coupon.
+ (BOOL)isCoupon:(NSString *)couponId reportedByUser:(NSString *)userId {
    NSDictionary *data = [self readDataFile:kReportCouponLocalPathName];
    NSArray *list = data[userId];
    if ([list containsObject:couponId]) {
        return YES;
    }
    return NO;
}

+ (void)reportCoupon:(NSString *)couponId fromUser:(NSString *)userId {
    if (userId.length <= 0 || couponId.length <= 0) {
        return;
    }
    NSMutableDictionary *data = [[self readDataFile:kReportCouponLocalPathName] mutableCopy];
    if (!data) {
        data = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    NSMutableArray *list = [data[userId] mutableCopy];
    if (!list) {
        list = [NSMutableArray arrayWithCapacity:0];
    }
    if ([list containsObject:couponId]) {
        return;
    }
    [list addObject:couponId];
    [data setObject:list forKey:userId];
    [self saveDataFile:data toFile:kReportCouponLocalPathName];
}

// Mark plist.
+ (NSDictionary *)markPlist {
    return [self readDataFile:kMarkObjectLocalPathName];
}

+ (BOOL)isObject:(Class)klass markedForId:(NSString *)objId {
    NSDictionary *data = [self markPlist];
    NSArray *list = data[NSStringFromClass(klass)];
    if ([list containsObject:objId]) {
        return YES;
    }
    return NO;
}

+ (void)markObject:(Class)klass forId:(NSString *)objId {
    if (!klass || objId.length == 0) {
        return;
    }
    NSMutableDictionary *data = [[self readDataFile:kMarkObjectLocalPathName] mutableCopy];
    if (!data) {
        data = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    NSString *key = NSStringFromClass(klass);
    NSMutableArray *list = [data[key] mutableCopy];
    if (!list) {
        list = [NSMutableArray arrayWithCapacity:0];
    }
    if ([list containsObject:objId]) {
        return;
    }
    [list addObject:objId];
    [data setObject:list forKey:key];
    [self saveDataFile:data toFile:kMarkObjectLocalPathName];
}
@end
