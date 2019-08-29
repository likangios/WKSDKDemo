//
//  ViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "ViewController.h"
#import <WebViewJavascriptBridge.h>
#import <PTFakeTouch/PTFakeMetaTouch.h>
#import <WebKit/WebKit.h>
@interface ViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>
@property(nonatomic,strong) UIWebView *webview;
@property(retain, nonatomic) UIView *containerView;

@property(nonatomic,copy) void(^cancleBlock)(void);
@property(nonatomic,copy) void(^sureBlock)(void);
@property(nonatomic,assign) BOOL stop;
@property(nonatomic,strong) WebViewJavascriptBridge *bridge;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"https://webcdn2.hsyuntai.com/page/app/hkyzh5_xh.html";
    
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)];
    [self.view addSubview:self.webview];
    self.webview.scrollView.bounces = NO;
    self.webview.delegate = self;

    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.backgroundColor =[UIColor grayColor];
    refresh.frame = CGRectMake(300, 500, 50, 50);
    [self.view addSubview:refresh];
    [refresh addTarget:self action:@selector(refrehClick) forControlEvents:UIControlEventTouchUpInside];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bridgeForWebView：%@",data);
        [self refrehClick];
    }];
    [self.bridge setWebViewDelegate:self];
    [self.bridge registerHandler:@"sliderVerificationCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"data：%@",data);
    }];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
dispatch_source_t timer;

- (void)YDD_cancelTimer{
    if (timer) {
        dispatch_source_cancel(timer);
    }
}


- (void)refrehClick{
    [self.webview reload];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
//    NSLog(@"webViewDidStartLoad");
}
- (void)moveToEnd:(CGFloat)endY currentY:(CGFloat)curY pointId:(NSInteger)pointId Height:(CGFloat)height{
    CGFloat randomTime = (float)(arc4random()%10) / 1000.0;
    CGFloat  randomOffset = arc4random()%100 + 100;
//    NSLog(@"randomTIme:%f  offset:%f",randomTime,randomOffset);
    __block CGFloat currentY = curY;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        currentY += randomOffset;
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseMoved];
        if (currentY < endY*2) {
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
//                [self refrehClick];
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
        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(23,height) withTouchPhase:UITouchPhaseBegan];
        [self moveToEnd:offsetX currentY:23 pointId:pointId Height:height];
    });
}
/*
- (void)YDD_resumeTimer{
    [self YDD_cancelTimer];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSInteger rate = 100;
    dispatch_source_set_timer(timer,DISPATCH_TIME_NOW,1.0/rate*NSEC_PER_SEC, 0); //每秒执行5次
    
    CGFloat height = 44 + UIApplication.sharedApplication.statusBarFrame.size.height + 65 + 26;
    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(23,height) withTouchPhase:UITouchPhaseBegan];
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *script = [NSString stringWithFormat:@"document.getElementsByClassName('button')[0].offsetLeft"];
            NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:script];
            CGFloat offsetX = UIScreen.mainScreen.bounds.size.width - 46 - 52;
            NSLog(@"result:%@",result);
            if (result.integerValue >= offsetX) {
                [self moveWithCurrentY:result.integerValue pointId:pointId shouldEnd:YES];
            }
            else{
                [self moveWithCurrentY:result.integerValue pointId:pointId shouldEnd:NO];
            }
        });
    });
    dispatch_resume(timer);
}
- (void)moveWithCurrentY:(CGFloat)curY pointId:(NSInteger)pointId shouldEnd:(BOOL)end{
    CGFloat randomTime = (float)(arc4random()%10) / 1000.0;
    CGFloat  randomOffset = arc4random()%150;
    NSLog(@"randomTIme:%f  offset:%f",randomTime,randomOffset);
    CGFloat height = 44 + UIApplication.sharedApplication.statusBarFrame.size.height + 65 + 26;
    __block CGFloat currentY = curY;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        currentY += randomOffset;
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseMoved];
        if (end) {
            [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseEnded];
        }
    });
}
- (void)moveToEnd:(CGFloat)endY currentY:(CGFloat)curY pointId:(NSInteger)pointId Height:(CGFloat)height{
    CGFloat randomTime = (float)(arc4random()%10) / 1000.0;
    CGFloat  randomOffset = arc4random()%150;
    NSLog(@"randomTIme:%f  offset:%f",randomTime,randomOffset);
//    randomOffset = MIN(endY - curY, randomOffset);
    __block CGFloat currentY = curY;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        currentY += randomOffset;
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseMoved];
        if (currentY < endY) {
            [self moveToEnd:endY currentY:currentY pointId:pointId Height:height];
        }
        else{
            [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(currentY,height) withTouchPhase:UITouchPhaseEnded];
        }
    });
}
*/
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    NSLog(@"didFailLoadWithError");

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSLog(@"request:%@===%@",request.URL,request.allHTTPHeaderFields);
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
@end
