//
//  SliderViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/9/1.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "SliderViewController.h"

#import <WebViewJavascriptBridge.h>
#import <WKWebViewJavascriptBridge.h>
#import <PTFakeTouch/PTFakeMetaTouch.h>
#import <WebKit/WebKit.h>
#import "CCNetworkMananger.h"
#import "CodeManager.h"


@interface SliderViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>
//@property(nonatomic,strong) UIWebView *webview;
@property(nonatomic,strong) WKWebView *webview;

@property(retain, nonatomic) UIView *containerView;

@property(nonatomic,copy) void(^cancleBlock)(void);
@property(nonatomic,copy) void(^sureBlock)(void);
@property(nonatomic,assign) BOOL stop;
//@property(nonatomic,strong) WebViewJavascriptBridge *bridge;
@property(nonatomic,strong) WKWebViewJavascriptBridge *bridge;

@property(nonatomic,assign) CGFloat rate;

//@property(nonatomic,assign) NSInteger errorCount;
@property(nonatomic,strong)   UIButton *countLabel;

@property(nonatomic,strong) UIButton *deleteCode;
@property(nonatomic,assign) BOOL isRequesting;
@property (nonatomic,strong) dispatch_source_t timer;

@end
static NSInteger errorCount = 0;
@implementation SliderViewController

- (void)cleanCodel{
    [[[CCNetworkMananger shareInstance] getGuoQiCode] subscribeNext:^(NSArray * x) {
        if ([x isKindOfClass:[NSArray class]]) {
            [[[CCNetworkMananger shareInstance] removeObjects:x] subscribeNext:^(id  _Nullable x) {
            }];
        }
    }];
}
- (void)dealloc{
    NSLog(@"====================dealloc");
    dispatch_cancel(self.timer);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        [self cleanCodel];
    });
    dispatch_resume(self.timer);

    [self webview];
    UIButton *exit = [UIButton buttonWithType:UIButtonTypeCustom];
    exit.backgroundColor =[UIColor orangeColor];
    if (isDefault == 1) {
        exit.backgroundColor =[UIColor grayColor];
    }
    
    
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
    refresh.backgroundColor =[UIColor greenColor];
    if (isDefault == 1) {
        refresh.backgroundColor =[UIColor grayColor];
    }
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
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self exitApp];
//    });
}
- (void)getCode{
    self.isRequesting = YES;
    AVQuery *query = [AVQuery queryWithClassName:@"CodePool"];
    [query orderByAscending:@"createdAt"];
//    [query selectKeys:@[@"slider_token", @"slider_sessionid",@"slider_sig"]];
    [query selectKeys:@[@"list"]];
    query.limit = 2;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray array];
            [objects enumerateObjectsUsingBlock:^(AVObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = [obj dictionaryForObject];
                [array addObjectsFromArray:dic[@"list"]];
            }];
            NSLog(@"array:%@",array);
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
        if (isDefault == 1) {
            _countLabel.backgroundColor = [UIColor grayColor];
        }
        else{
            [_countLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_countLabel setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        }
        _countLabel.selected = YES;
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
//        _deleteCode.hidden = YES;
        [_deleteCode actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    }
    return _deleteCode;
}

- (WKWebView *)webview{
    if (!_webview) {
        _webview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)];
        [self.view insertSubview:_webview atIndex:0];
        _webview.scrollView.bounces = NO;
        _webview.navigationDelegate = self;
        NSDate *date = [NSDate date];
        NSTimeInterval timeinterval = ([date timeIntervalSince1970] + 86400) * 1000;
        NSString *url = [NSString stringWithFormat:@"https://webcdn2.hsyuntai.com/page/app/hkyzh5_xh.html?t=%.f",timeinterval];
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        @weakify(self);
        self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webview handler:^(id data, WVJBResponseCallback responseCallback) {
            errorCount = 0;
            @strongify(self);
            CodeModel *model = [CodeModel mj_objectWithKeyValues:data[@"validResult"]];
            [[CodeManager shareInstance].codeArray addObject:model];
            if ([CodeManager shareInstance].codeArray.count > 19) {
                NSArray *copyArray = [[CodeManager shareInstance].codeArray copy];
                [[CodeManager shareInstance].codeArray removeAllObjects];
                [[[CCNetworkMananger shareInstance] addCodeArray:copyArray] subscribeNext:^(id  _Nullable x) {
                    if ([x isKindOfClass:[NSError class]]) {
                        NSError *error = (NSError *)x;
                        NSLog(@"添加失败:%@",error);
                    }
                } completed:^{
                    NSLog(@"添加完成");
                }];
                
            }
            [self.webview reload];
        }];
        /*
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
         */
        [self.bridge setWebViewDelegate:self];
        [self.bridge registerHandler:@"sliderVerificationCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        }];
        
    }
    return _webview;
}
- (void)getAllCodeCount{
//    [self getCode];
    self.countLabel.selected = !self.countLabel.selected;
    @weakify(self);
    [[[CCNetworkMananger shareInstance] getAllCodeCount] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (![x isKindOfClass:[NSError class]]) {
            NSNumber *count = (NSNumber *)x;
            [self.countLabel setTitle:[NSString stringWithFormat:@"总量：%d",count.intValue * 20] forState:UIControlStateNormal];
        }
    }];
}

- (void)removeAllCode{
//    [[[CCNetworkMananger shareInstance] removeAll] subscribeNext:^(id  _Nullable x) {
//        if ([x isKindOfClass:[NSError class]]) {
//        }
//        else{
//        }
//    }];
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
- (void)refrehClick2{
    NSLog(@"refrehClick2");
    NSString*cachePath =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webkitPath = [libDir stringByAppendingPathComponent:@"WebKit"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:webkitPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:webkitPath error:nil];
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
    if ([[[NSBundle mainBundle] bundleIdentifier] containsString:@"333"]) {
        [self isOpenApp:@"com.slider.xh.demo222"];
    }
    else{
        [self isOpenApp:@"com.slider.xh.demo333"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}
- (BOOL)isOpenApp:(NSString*)appIdentifierName
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    BOOL isOpenApp = [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appIdentifierName];
    return isOpenApp;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    //    NSLog(@"webViewDidStartLoad");
}
- (void)moveToEnd:(CGFloat)endY currentY:(CGFloat)curY pointId:(NSInteger)pointId Height:(CGFloat)height{
    CGFloat randomTime = (float)(arc4random()%10) / 500.0;
    CGFloat  randomOffset = arc4random()%300 + 200;
//    CGFloat  randomOffset = 500;
    __block CGFloat currentY = curY;
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        currentY += randomOffset;
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseMoved];
        if (currentY < endY) {
            [self moveToEnd:endY currentY:currentY pointId:pointId Height:height];
        }
        else{
            [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseEnded];
            NSString *script = [NSString stringWithFormat:@"document.getElementsByClassName('button')[0].offsetLeft"];
            [self.webview evaluateJavaScript:script completionHandler:^(NSNumber *result, NSError * _Nullable error) {
                CGFloat offsetX = UIScreen.mainScreen.bounds.size.width - 46 - 52;
                if (result.integerValue < offsetX) {
                    [self startMove];
                }
                else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSString *script = [NSString stringWithFormat:@"document.getElementsByClassName('stage stage3')[0].style.display"];
                        [self.webview evaluateJavaScript:script completionHandler:^(NSString *result, NSError * _Nullable error) {
                            if (![result isEqualToString:@"none"]) {
                                errorCount ++;
//                                if (errorCount > 3) {
//                                    [self exitApp];
//                                }
                                [self refrehClick2];
                            }
                        }];
                    });
                }

            }];
//            NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:script];
            //            NSLog(@"result:%@",result);
        }
    });
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self startMove];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //    NSLog(@"webViewDidFinishLoad");
    [self startMove];
}
- (void)startMove{
        CGFloat height = UIApplication.sharedApplication.statusBarFrame.size.height + 26;
//    CGFloat height = 44 ;
    CGFloat offsetX = UIScreen.mainScreen.bounds.size.width - 23 - 52;
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
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
/*
- (void)moveToOffset:(CGFloat)offset{
    
    NSString *script1 = [NSString stringWithFormat:@"document.getElementsByClassName('button')[0].style.left = %f",offset];
    NSString *script2 = [NSString stringWithFormat:@"document.getElementsByClassName('track')[0].style.width = %f",offset+26];
        [self.webview stringByEvaluatingJavaScriptFromString:script1];
        [self.webview stringByEvaluatingJavaScriptFromString:script2];
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
