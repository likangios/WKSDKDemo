//
//  ViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//
#import "ViewController.h"
#import "SliderViewController.h"
#import "CCNetworkMananger.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <stdlib.h>
#import <mach-o/dyld.h>



@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,assign) NSInteger firstRow;
@property(nonatomic,assign) NSInteger secondRow;
@property(nonatomic,assign) NSInteger thirdRow;
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
- (void)isOK1 {
    //可能存在hook了NSFileManager方法，此处用底层C stat去检测
    //    /Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate
    //    /Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装
    struct stat stat_info;
    if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/var/lib/cydia/", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/var/cache/apt", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/var/lib/apt", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/etc/apt", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/bin/bash", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/bin/sh", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/usr/sbin/sshd", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/usr/libexec/ssh-keysign", &stat_info)) {
        exit(0);
    }
    if (0 == stat("/etc/ssh/sshd_config", &stat_info)) {
        exit(0);
    }
}
void printEnv(void){
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        exit(0);
    }
}
void checkDylibs(void){
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
        if ([name containsString:@"MobileSubstrate.dylib"]) {
            exit(0);
        }
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self isOK1];
    printEnv();
    checkDylibs();
//    UIColor *defaultColor = [UIColor purpleColor];
//    UIColor *defaultColor = [UIColor grayColor];
    /*
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    UIControl *bgView = [[UIControl alloc]initWithFrame:CGRectMake(0, height - 220 , width, 220)];
    [self.view addSubview:bgView];
    bgView.tag = 567;
    bgView.hidden = YES;
    bgView.backgroundColor = [UIColor grayColor];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.frame = CGRectMake(0, 0, 50, 40);
    cancel.backgroundColor = [UIColor grayColor];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancel];
    
    UIButton *confirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirm setTitle:@"确定" forState:UIControlStateNormal];
    confirm.frame = CGRectMake(width - 50, 0, 50, 40);
    confirm.backgroundColor = [UIColor grayColor];
    [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(confirmPicker) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:confirm];
    
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40 , width, 180)];
    picker.backgroundColor = [UIColor grayColor];
    picker.delegate = self;
    [bgView addSubview:picker];
     */
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UIView *view = [self.view viewWithTag:567];
//    view.hidden = NO;
//    double new = 8 * 3600;
    NSTimeInterval  time = [[NSDate date] timeIntervalSince1970];
//    NSInteger shijc =  time + 8 * 3600000 - ((time + 8 * 3600000)/86400000 * 86400000);
//    NSLog(@"time:%f",time);
//    NSLog(@"shijc:%f",shijc);
    
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [greCalendar setTimeZone: timeZone];
    
    NSDateComponents *dateComponents = [greCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:[NSDate date]];
    
    //  定义一个NSDateComponents对象，设置一个时间点
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    [dateComponentsForDate setDay:dateComponents.day];
    [dateComponentsForDate setMonth:dateComponents.month];
    [dateComponentsForDate setYear:dateComponents.year];
    [dateComponentsForDate setHour:0];
    [dateComponentsForDate setMinute:14];
    [dateComponentsForDate setSecond:00];
    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];
    NSTimeInterval  time2 = [dateFromDateComponentsForDate timeIntervalSince1970];
    NSLog(@"%f",time);
    NSLog(@"%f",time2);
}
- (void)cancelPicker{
    UIView *view = [self.view viewWithTag:567];
    view.hidden = NO;
}
- (void)confirmPicker{
    NSInteger time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger shijc =  time % 86400 + 8 * 3600;
    NSLog(@"当前时间：%ld",shijc);
    NSLog(@"选择开始日期：%ld：%ld %ld",self.firstRow,self.secondRow,self.thirdRow);
    NSLog(@"时间戳：%.f",self.firstRow * 3600.0 + self.secondRow * 60.0 + self.thirdRow);
    UIView *view = [self.view viewWithTag:567];
    view.hidden = NO;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 24;
    }
    else{
        return 60;
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld",row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"(%ld,%ld)",component,row);
    if (component == 0) {
        self.firstRow = row;
    }
    else if (component == 1){
        self.secondRow = row;
    }
    else{
        self.thirdRow = row;
    }
}
@end
