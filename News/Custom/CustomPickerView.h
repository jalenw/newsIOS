//
//  CustomPickerView.h
//  zingchat
//
//  Created by index on 16/6/23.
//  Copyright © 2016年 Miju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPickerView;

@protocol CustomPickerViewDelegate <NSObject>

- (void)customPickerViewDidSelected:(CustomPickerView*)view date:(NSDate*)date dateString:(NSString*)dateString;

- (void)customPickerViewDidSelected:(CustomPickerView*)view customDict:(NSDictionary*)dict;

@end

@interface CustomPickerView : UIView

+ (id)datePickerView:(UIDatePickerMode)model;
+ (void)showDatePickerView;

+ (id)customPickerViewWithArray:(NSArray<NSArray*>*)array key:(NSString*)key;
+ (id)customPickerWithChannel;

- (void)showPicker;
- (void)dismissPicker;


@property (nonatomic, weak) id<CustomPickerViewDelegate> delegate;

@end
