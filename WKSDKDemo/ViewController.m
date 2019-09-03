//
//  ViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "ViewController.h"
#import "SliderViewController.h"

@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SliderViewController *slider = [[SliderViewController alloc]init];
        [self.navigationController pushViewController:slider animated:NO];
    });
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
@end
