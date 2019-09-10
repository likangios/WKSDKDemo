//
//  CodeManager.m
//  WKSDKDemo
//
//  Created by luck on 2019/9/10.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "CodeManager.h"

@implementation CodeManager

static CodeManager *_instance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc]init];
    });
    return _instance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _codeArray = [NSMutableArray array];
    }
    return self;
}
@end
