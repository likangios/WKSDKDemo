//
//  SliderViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/9/1.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "SliderViewController.h"

#import <WebViewJavascriptBridge.h>
#import <PTFakeTouch/PTFakeMetaTouch.h>
#import <WebKit/WebKit.h>
#import "CCNetworkMananger.h"


@interface SliderViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>
@property(nonatomic,strong) UIWebView *webview;
@property(retain, nonatomic) UIView *containerView;

@property(nonatomic,copy) void(^cancleBlock)(void);
@property(nonatomic,copy) void(^sureBlock)(void);
@property(nonatomic,assign) BOOL stop;
@property(nonatomic,strong) WebViewJavascriptBridge *bridge;
@property(nonatomic,assign) NSInteger requestCount;
@property(nonatomic,strong)   UIButton *countLabel;

@property(nonatomic,strong) UIButton *deleteCode;
@property(nonatomic,assign) BOOL isRequesting;

@end



@implementation SliderViewController

- (void)getCode{
    self.isRequesting = YES;
    AVQuery *query = [AVQuery queryWithClassName:@"CodePool"];
    [query orderByAscending:@"createdAt"];
    [query selectKeys:@[@"slider_token", @"slider_sessionid",@"slider_sig"]];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray array];
            [objects enumerateObjectsUsingBlock:^(AVObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = [obj dictionaryForObject];
                [array addObject:dic];
            }];
        }
        self.isRequesting = NO;
        [self deleteObjes:objects];
    }];
}
- (void)deleteObjes:(NSArray *)objs{
    [AVObject deleteAllInBackground:objs block:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除验证码错误：%@",error);
            [self deleteObjes:objs];
        }
        else{
            NSLog(@"删除验证码成功");
        }
    }];
}

- (UIButton *)countLabel{
    if (!_countLabel) {
        _countLabel  =[UIButton buttonWithType:UIButtonTypeCustom];
        [_countLabel setTitle:@"总量：0" forState:UIControlStateNormal];
        _countLabel.backgroundColor =[UIColor grayColor];
        [_countLabel addTarget:self action:@selector(getAllCodeCount) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countLabel;
}
- (UIButton *)deleteCode{
    if (!_deleteCode) {
        _deleteCode  =[UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteCode setTitle:@"清空验证码" forState:UIControlStateNormal];
        _deleteCode.backgroundColor =[UIColor grayColor];
        [_deleteCode addTarget:self action:@selector(removeAllCode) forControlEvents:UIControlEventTouchUpInside];
        _deleteCode.hidden = YES;
    }
    return _deleteCode;
}
- (void)showVerificationView{
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}
- (UIWebView *)webview{
    if (!_webview) {
        _webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)];
        [self.view insertSubview:_webview atIndex:0];
        _webview.scrollView.bounces = NO;
        _webview.delegate = self;
        NSDate *date = [NSDate date];
        NSTimeInterval timeinterval = [date timeIntervalSince1970] * 1000;
        NSString *url = [NSString stringWithFormat:@"https://webcdn2.hsyuntai.com/page/app/hkyzh5_xh.html?t=%.f",timeinterval];
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webview handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
            CodeModel *model = [CodeModel mj_objectWithKeyValues:data[@"validResult"]];
            [[[CCNetworkMananger shareInstance] AddCode:model] subscribeNext:^(id x) {
                if ([x isKindOfClass:[NSError class]]) {
                    NSError *error = (NSError *)x;
                    NSLog(@"添加失败:%@",error);
                }
            } completed:^{
                NSLog(@"添加完成");
            }];
            [self.webview reload];
        }];
        [self.bridge setWebViewDelegate:self];
        [self.bridge registerHandler:@"sliderVerificationCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"data：%@",data);
        }];
        
    }
    return _webview;
}
- (void)getAllCodeCount{
    [[[CCNetworkMananger shareInstance] getAllCodeCount] subscribeNext:^(id  _Nullable x) {
        if (![x isKindOfClass:[NSError class]]) {
            NSNumber *count = (NSNumber *)x;
            [self.countLabel setTitle:[NSString stringWithFormat:@"总量：%d",count.intValue] forState:UIControlStateNormal];
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *arr;
    self.requestCount = 0;
    [self webview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVerificationView) name:@"showVerificationView" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showVerificationView" object:nil];
    
    UIButton *exit = [UIButton buttonWithType:UIButtonTypeCustom];
    exit.backgroundColor =[UIColor grayColor];
    [exit setTitle:@"退出" forState:UIControlStateNormal];
    [self.view addSubview:exit];
    [exit addTarget:self action:@selector(exitApp) forControlEvents:UIControlEventTouchUpInside];
    [exit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
    }];
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.backgroundColor =[UIColor grayColor];
    refresh.frame = CGRectMake(100, 500, 150, 50);
    [refresh setTitle:@"刷新" forState:UIControlStateNormal];
    [self.view addSubview:refresh];
    [refresh addTarget:self action:@selector(refrehClick2) forControlEvents:UIControlEventTouchUpInside];
    
    [refresh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(exit.mas_top).offset(-10);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(refresh.mas_left);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(refresh.mas_top).offset(-10);
        make.width.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.deleteCode];
    [self.deleteCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.countLabel.mas_right).offset(10);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(refresh.mas_top).offset(-10);
        make.width.mas_equalTo(100);
    }];
    [self getAllCodeCount];
    
}
- (void)removeAllCode{
    [[[CCNetworkMananger shareInstance] getAllCode] subscribeNext:^(id  _Nullable x) {
        if ([x isKindOfClass:[NSError class]]) {
        }
        else{
            NSArray *objs = (NSArray *)x;
            [[[CCNetworkMananger shareInstance] removeObjects:objs] subscribeNext:^(id  _Nullable x) {
                if (![x isKindOfClass:[NSError class]]) {
                    [self showHUDMessage:@"OK"];
                    [self getAllCodeCount];
                }
            }];
        }
    }];
}
- (void)dealloc{
    NSLog(@"====================dealloc");
}
- (void)refrehClick2{
    NSLog(@"refrehClick2");
    NSString*cachePath =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    [self cleanCacheAndCookie];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [self.webview removeFromSuperview];
    self.webview = nil;
    [self webview];
    [self.navigationController popViewControllerAnimated:NO];
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

//刷新
- (void)exitApp{
    exit(0);
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    //    NSLog(@"webViewDidStartLoad");
}
- (void)moveToEnd:(CGFloat)endY currentY:(CGFloat)curY pointId:(NSInteger)pointId Height:(CGFloat)height{
    CGFloat randomTime = (float)(arc4random()%10) / 1000.0;
    CGFloat  randomOffset = arc4random()%500;
    //    NSLog(@"randomTIme:%f  offset:%f",randomTime,randomOffset);
    __block CGFloat currentY = curY;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        currentY += randomOffset;
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseMoved];
        if (currentY < endY) {
            [self moveToEnd:endY currentY:currentY pointId:pointId Height:height];
        }
        else{
            [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseEnded];
            NSString *script = [NSString stringWithFormat:@"document.getElementsByClassName('button')[0].offsetLeft"];
            NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:script];
            CGFloat offsetX = UIScreen.mainScreen.bounds.size.width - 46 - 52;
            //            NSLog(@"result:%@",result);
            if (result.integerValue < offsetX) {
                [self startMove];
            }
            else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *script = [NSString stringWithFormat:@"document.getElementsByClassName('stage stage3')[0].style.display"];
                    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:script];
                    if (![result isEqualToString:@"none"]) {
                        [self refrehClick2];
                    }
                });
            }
        }
    });
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //    NSLog(@"webViewDidFinishLoad");
    [self startMove];
    
}
- (void)startMove{
    //    CGFloat height = 44 + UIApplication.sharedApplication.statusBarFrame.size.height + 65 + 26;
    CGFloat height = 44 ;
    CGFloat offsetX = UIScreen.mainScreen.bounds.size.width - 23 - 52;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:1 AtPoint:CGPointMake(23,height) withTouchPhase:UITouchPhaseBegan];
        [self moveToEnd:offsetX currentY:23 pointId:pointId Height:height];
    });
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError:%@",error);
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request:%@===%@",request.URL,request.allHTTPHeaderFields);
    return YES;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.allObjects.firstObject;
    CGPoint  local = [touch locationInView:self.view];
    NSLog(@"local.y:%f",local.x);
    //    [self moveToOffset:local.x];
}
- (void)moveToOffset:(CGFloat)offset{
    
    NSString *script1 = [NSString stringWithFormat:@"document.getElementsByClassName('button')[0].style.left = %f",offset];
    NSString *script2 = [NSString stringWithFormat:@"document.getElementsByClassName('track')[0].style.width = %f",offset+26];
    //    [self.webview stringByEvaluatingJavaScriptFromString:script1];
    //    [self.webview stringByEvaluatingJavaScriptFromString:script2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
