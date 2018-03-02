//
//  HomeCoupon.h
//  SQDataBaseManage
//
//  Created by lhq on 2018/2/26.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeCoupon : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *couponId;
@property (nonatomic, assign) NSTimeInterval timestamp; // for db - save time
@property (nonatomic, assign) NSTimeInterval c_timestamp; // for db - received coupon time
@property (nonatomic, assign) BOOL history; // for history db.
@property (nonatomic, assign) BOOL couponHasReceive; // for received history db.
@end
