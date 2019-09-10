//
//  CodeManager.h
//  WKSDKDemo
//
//  Created by luck on 2019/9/10.
//  Copyright © 2019年 ting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeManager : NSObject
@property(nonatomic,strong) NSMutableArray *codeArray;
+ (instancetype)shareInstance;
@end
