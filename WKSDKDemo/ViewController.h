//
//  ViewController.h
//  WKSDKDemo
//
//  Created by luck on 2019/8/21.
//  Copyright © 2019年 ting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface ViewController : UIViewController

@property(nonatomic,strong) NSMutableArray *cacheDic;

- (void)cancelPicker;
- (void)confirmPicker;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
@end

