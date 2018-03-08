//
//  SQUser.m
//  SQDataBaseManageDemo
//
//  Created by lhq on 2018/3/8.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import "SQUser.h"

@implementation SQUser
+ (NSString *)getTableName {
    return @"user";
}

+ (NSString *)getPrimaryKey {
    return @"userId";
}
@end
