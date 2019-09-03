//
//  CodeModel.m
//  WKSDKDemo
//
//  Created by luck on 2019/9/2.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "CodeModel.h"

@implementation CodeModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"slider_token":@"value",
             @"slider_sessionid":@"csessionid",
             @"slider_sig":@"sig"
             };
}
@end
