//
//  ViewController.m
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//

#import "ViewController.h"
#import "SliderViewController.h"

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
- (void)viewDidLoad{
    [super viewDidLoad];
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
}
- (void)cancelPicker{
    UIView *view = [self.view viewWithTag:567];
    view.hidden = NO;
}
- (void)confirmPicker{
    NSInteger time = [[NSDate date] timeIntervalSince1970];
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
