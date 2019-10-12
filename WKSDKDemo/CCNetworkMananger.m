//
//  CCNetworkMananger.m
//  WKSDKDemo
//
//  Created by luck on 2019/9/2.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "CCNetworkMananger.h"

@interface CCNetworkMananger ()

@end

@implementation CCNetworkMananger

static CCNetworkMananger *_instance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc]init];
    });
    return _instance;
}
- (RACSignal *)removeObjects:(NSArray *)all{
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [AVObject deleteAllInBackground:all block:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:@(YES)];
            }
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}
- (RACSignal *)removeAll{
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AVObject *avobj = [AVObject objectWithClassName:@"CodePool"];
        [avobj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:@(succeeded)];
            }
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}

- (RACSignal *)getAllCodeCount{
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AVQuery *query = [AVQuery queryWithClassName:@"CodePool"];
        [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:@(number)];
            }
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

- (RACSignal *)getAllCode{
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AVQuery *query = [AVQuery queryWithClassName:@"CodePool"];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:objects];
            }
                [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}
- (RACSignal *)addCodeArray:(NSArray *)codes{
    
    NSMutableArray *avobjArray = [NSMutableArray array];
    [codes enumerateObjectsUsingBlock:^(CodeModel  *model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = [model mj_keyValues];
        AVObject *avobj = [AVObject objectWithClassName:@"CodePool"];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![key isEqualToString:@"objectId"]) {
                [avobj setObject:obj forKey:key];
            }
        }];
        [avobjArray addObject:avobj];
    }];
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [AVObject saveAllInBackground:avobjArray block:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:@(YES)];
            }
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
}
- (RACSignal *)AddCode:(CodeModel *)model{
    return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AVObject *avobj = [AVObject objectWithClassName:@"CodePool"];
        NSDictionary *dic = [model mj_keyValues];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![key isEqualToString:@"objectId"]) {
                [avobj setObject:obj forKey:key];
            }
        }];
        [avobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [subscriber sendNext:error];
            }
            else{
                [subscriber sendNext:@(YES)];
            }
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}

@end
