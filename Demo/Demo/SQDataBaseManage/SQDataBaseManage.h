//
//  SQDataBaseManage.h
//  SQDataBaseManage
//
//  Created by lhq on 2018/2/26.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LKDBHelper/LKDBHelper.h>

typedef NS_ENUM(NSInteger,DBWhereType) {
    DBWhereTypeReceived,
    DBWhereTypeHistory,
};

@interface SQDataBaseManage : NSObject

/** database core manage */
+ (LKDBHelper *)defaultLKDBHelper;

/** one model to one table */
+ (void)addObject:(id)object;
+ (void)addObject:(id)object callback:(void (^)(BOOL result))callback;

+ (void)updataObject:(id)object where:(NSString *)where;
+ (void)updataObject:(id)object where:(NSString *)where callback:(void (^)(BOOL result))callback;

+ (void)deleteObject:(id)object;
+ (void)deleteObject:(id)object callback:(void (^)(BOOL result))callback;

+ (id)objectSingle:(Class)modelClass where:(id)where orderBy:(NSString *)orderBy;
+ (NSArray *)objectsWithModelClass:(Class)modelClass where:(NSString *)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count;
+ (void)objectsWithModelClass:(Class)modelClass where:(NSString *)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count callback:(void (^)(NSMutableArray *array))callback;

/** one model to many table */
+ (void)addObject:(id)object whereType:(DBWhereType)whereType;
+ (void)addObject:(id)object whereType:(DBWhereType)whereType callback:(void (^)(BOOL result))callback;

+ (void)deleteObject:(id)object whereType:(DBWhereType)whereType;
+ (void)deleteObject:(id)object whereType:(DBWhereType)whereType callback:(void (^)(BOOL result))callback;

+ (NSArray *)objectsWithDBWhereType:(DBWhereType)whereType page:(NSInteger)page pageSize:(NSInteger)pageSize;

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)saveDataFile:(id)data toFile:(NSString *)filename;
+ (id)readDataFile:(NSString*)filename;
+ (NSData *)readDataWithFileName:(NSString*)filename;

/// AppConfiguration
//+ (AppInitConfiguration *)appInitConfiguration;
//+ (BOOL)saveAppInitConfiguration:(AppInitConfiguration *)configuration;
//+ (NSString *)localJSFilePath;

/// App cahe
+ (CGFloat)appCacheSize; // return kb size.
+ (NSString *)appCacheSizeString;
+ (void)clearAppCacheCompletion:(void(^)(CGFloat leftSize, NSString *leftSizeStr))completion;

/// Search history
+ (NSArray *)searchHistoryList;
+ (BOOL)saveSearchHistoryList:(NSArray *)historys;
+ (BOOL)saveSearchHistory:(NSString *)search;
+ (BOOL)clearAllSearchHistory;
+ (BOOL)clearSearchHistory:(NSString *)search;
+ (void)synchronizeHistoryToServer;
+ (void)synchronizeHistoryToServer:(NSString *)searchText;

/// Report coupon.
+ (BOOL)isCoupon:(NSString *)couponId reportedByUser:(NSString *)userId;
+ (void)reportCoupon:(NSString *)couponId fromUser:(NSString *)userId;

/// Mark plist.
+ (NSDictionary *)markPlist;
+ (BOOL)isObject:(Class)klass markedForId:(NSString *)objId;
+ (void)markObject:(Class)klass forId:(NSString *)objId;
@end
