//
//  CustomPickerView.m
//  zingchat
//
//  Created by index on 16/6/23.
//  Copyright © 2016年 Miju. All rights reserved.
//

#import "CustomPickerView.h"

typedef enum: NSInteger{
    CustomPickerStyleTypeDate = 2,
    CustomPickerStyleTypeCustom = 99,
}CustomPickerStyleType;

@interface CustomPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    CustomPickerStyleType _styleType;
    UIView *_pickerContainerView;
    
    UIPickerView *_pickerView;
    
    NSInteger _currentProvinceIndex;
    NSInteger _currentCityIndex;
    NSInteger _currentDistrictIndex;
    
    
    UIDatePicker *_datePicker;
    
    NSArray *_customArray;}


@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *key;


@end

@implementation CustomPickerView

- (void)showPicker{
    [AppDelegateInstance.window addSubview:self];
    [UIView animateWithDuration:0.275 animations:^{
        _pickerContainerView.bottom = ScreenHeight;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissPicker{
    [UIView animateWithDuration:0.275 animations:^{
        _pickerContainerView.top = ScreenHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


+ (id)datePickerView:(UIDatePickerMode)model
{
    static dispatch_once_t predicate = 0;
    static CustomPickerView *DatepickerView = nil;
    dispatch_once(&predicate, ^{
        DatepickerView = [[self alloc] init] ;
        [DatepickerView setupDatePicker];
    });
    [DatepickerView setupModel:model];
    return DatepickerView;
}

+ (void)showDatePickerView{
    CustomPickerView *picker = [self datePickerView:UIDatePickerModeDateAndTime];
    [AppDelegateInstance.window addSubview:picker];
    [picker showPicker];
}

- (void)setupModel:(UIDatePickerMode)model
{
    _datePicker.datePickerMode = model;
}

- (void)setupDatePicker{
    _styleType = CustomPickerStyleTypeDate;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM月dd日HH时mm分"];
    self.frame = ScreenBounds;
    self.backgroundColor = RGBA(0, 0, 0, 0.8);
    UIButton *maskButton = [[UIButton alloc] initWithFrame:ScreenBounds];
    [maskButton addTarget:self action:@selector(cancelChangeDate:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maskButton];
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"en_GB"];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    //_datePicker.maximumDate = [NSDate date];
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.width = ScreenWidth;
    _pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _datePicker.height+52)];
    _pickerContainerView.backgroundColor = [UIColor clearColor];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _datePicker.height+8, ScreenWidth, 44)];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"确定" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(comfirmBirthday:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pickerContainerView.top = ScreenHeight;
    [self addSubview:_pickerContainerView];
    [_pickerContainerView addSubview:cancelButton];
    [_pickerContainerView addSubview:_datePicker];
}

- (void)cancelChangeDate:(UIButton*)button{
    [self dismissPicker];
}

- (void)comfirmBirthday:(UIButton*)button{
    NSDate *date = _datePicker.date;
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    [self cancelChangeDate:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customPickerViewDidSelected:date:dateString:)]) {
        [self.delegate customPickerViewDidSelected:self date:date dateString:dateString];
    }
}


+ (id)customPickerViewWithArray:(NSArray*)array key:(NSString *)key{
    static dispatch_once_t predicate = 0;
    static CustomPickerView *CustompickerView = nil;
    dispatch_once(&predicate, ^{
        CustompickerView = [[self alloc] init] ;
        [CustompickerView setupCustomPicker];
    });
    CustompickerView.key = key;
    [CustompickerView setCustomArray:array];
    return CustompickerView;
}

+ (id)customPickerWithChannel
{
    static dispatch_once_t predicate = 0;
    static CustomPickerView *CustompickerViewCHannel = nil;
    dispatch_once(&predicate, ^{
        CustompickerViewCHannel = [[self alloc] init] ;
        [CustompickerViewCHannel setupCustomPicker];
    });
    CustompickerViewCHannel.key = @"channel_content";
    [CustompickerViewCHannel showPicker];
    [CustompickerViewCHannel getChannelList];
    return CustompickerViewCHannel;
}

- (void)setCustomArray:(NSArray*)array{
    _customArray = array;
    [_pickerView reloadAllComponents];
}

- (void)getChannelList{
    if (_customArray.count>0) {
        return;
    }
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=channel" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSArray *like = [dict safeArrayForKey:@"like"];
            NSArray *dislike = [dict safeArrayForKey:@"dislike"];
            NSMutableArray *array = [NSMutableArray arrayWithArray:like];
            [array addObjectsFromArray:dislike];
            _customArray = @[array];
            [_pickerView reloadAllComponents];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)setupCustomPicker{
    _styleType = CustomPickerStyleTypeCustom;
    self.frame = ScreenBounds;
    self.backgroundColor = RGBA(0, 0, 0, 0.8);
    
    UIButton *maskButton = [[UIButton alloc] initWithFrame:ScreenBounds];
    [maskButton addTarget:self action:@selector(dismissPicker) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maskButton];
    
    _pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 214)];
    [self addSubview:_pickerContainerView];
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 162)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 170, ScreenWidth, 44)];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"确定" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(comfirmSelectCustom:) forControlEvents:UIControlEventTouchUpInside];
    [_pickerContainerView addSubview:_pickerView];
    [_pickerContainerView addSubview:cancelButton];
}

- (void)comfirmSelectCustom:(UIButton*)button{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < _customArray.count; ++i) {
        NSArray *array = _customArray[i];
        NSInteger row = [_pickerView selectedRowInComponent:i];
        NSString *string = array[row];
        dict[[NSString stringWithFormat:@"%d",i]] = string;
        dict[[NSString stringWithFormat:@"row%d",i]] = @(row);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customPickerViewDidSelected:customDict:)]) {
        [self.delegate customPickerViewDidSelected:self customDict:dict];
    }
    
    [self dismissPicker];
}




#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_styleType == CustomPickerStyleTypeCustom){
        return _customArray.count;
    }
    return 0;
}

//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    if (pickerView == self.sizePickerView) {
//        return @"尺寸";
//    }else if (pickerView == _districtPicker) {
//        return @"";
//    }
//    return @"";
//}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_styleType == CustomPickerStyleTypeCustom){
        NSArray *array = _customArray[component];
        return array.count;
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (component == 0) {
//        NSDictionary *dic = [self.province objectAtIndex:row];
//        NSString *key = [[dic allKeys] firstObject];
//        return key;
//    }
//    if (component == 1) {
//        NSDictionary *dic = [self.city objectAtIndex:row];
//        NSString *key = [[dic allKeys] firstObject];
//        return key;
//    }
//    if (component == 2) {
//        return [self.district objectAtIndex:row];
//    }
//    return nil;
//}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, 21)];
    label.textAlignment = NSTextAlignmentCenter;
    if(_styleType == CustomPickerStyleTypeCustom){
        NSDictionary *dict = _customArray[component][row];
        label.text = [dict safeStringForKey:self.key];
    }
    
    return label;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(_styleType == CustomPickerStyleTypeCustom){
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
