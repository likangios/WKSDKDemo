//
//  CCNetworkMananger.h
//  WKSDKDemo
//
//  Created by luck on 2019/9/2.
//  Copyright © 2019年 ting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeModel.h"
@interface CCNetworkMananger : NSObject
+ (instancetype)shareInstance;
- (RACSignal *)AddCode:(CodeModel *)model;
- (RACSignal *)getAllCodeCount;
- (RACSignal *)getAllCode;
- (RACSignal *)removeObjects:(NSArray *)all;
- (RACSignal *)addCodeArray:(NSArray *)codes;
@end

