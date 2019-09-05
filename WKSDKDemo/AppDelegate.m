//
//  AppDelegate.m
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)initAVOSCloud{
    [AVOSCloud setApplicationId:@"IJhTnFwGR17jMSbMchDk1kq8-gzGzoHsz" clientKey:@"SYxHQzNvcBgO2ePUXlyzI7iR"];
    [AVOSCloud setAllLogsEnabled:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initAVOSCloud];
    [NSObject mj_referenceReplacedKeyWhenCreatingKeyValues:NO];
    //get the original user-agent of webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"old agent :%@", oldAgent);
    //add my info to the new agent
    NSString *newAgent = [oldAgent stringByAppendingString:@" YuntaiClient/2.12.0"];
    NSLog(@"new agent :%@", newAgent);
    //regist the new agent
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
//    [self isOpenApp:@"com.slider.xh.demo222"];
}
- (BOOL)isOpenApp:(NSString*)appIdentifierName
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    BOOL isOpenApp = [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appIdentifierName];
    
    return isOpenApp;
}


@end
