//
//  ThemeManager.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ThemeManager.h"

#define kThemeTextFont           @"kThemeTextFont"
#define kThemeAutoDarkModel      @"kThemeAutoDarkModel"
#define kThemeIsDarkTheme        @"kThemeIsDarkTheme"
#define kThemeIsCloseAPNs        @"kThemeIsCloseAPNs"

static ThemeManager *themeManager;

@interface ThemeManager()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ThemeManager

+ (instancetype)instance{
    if (themeManager == nil) {
        themeManager = [[ThemeManager alloc]init];
    }
    return themeManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textFont = [[[NSUserDefaults standardUserDefaults]objectForKey:kThemeTextFont] intValue];
        _isDarkTheme = [[[NSUserDefaults standardUserDefaults]objectForKey:kThemeIsDarkTheme] boolValue];
        _isCloseAPNs = [[[NSUserDefaults standardUserDefaults]objectForKey:kThemeIsCloseAPNs] boolValue];
    }
    return self;
}
- (void)loadModel
{
    self.isAutoDarkModel = [[[NSUserDefaults standardUserDefaults]objectForKey:kThemeAutoDarkModel] boolValue];
}

- (void)setTextFont:(int)textFont
{
    _textFont = textFont;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:textFont] forKey:kThemeTextFont];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationModelFontChange object:nil userInfo:nil];
}

- (void)setIsDarkTheme:(BOOL)isDarkTheme
{
    _isDarkTheme = isDarkTheme;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:isDarkTheme] forKey:kThemeIsDarkTheme];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationModelColorChange object:nil userInfo:nil];
}

- (void)setIsCloseAPNs:(BOOL)isCloseAPNs
{
    _isCloseAPNs = isCloseAPNs;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:isCloseAPNs] forKey:kThemeIsCloseAPNs];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationModelAPNsChange object:nil userInfo:nil];
}

- (void)setIsAutoDarkModel:(BOOL)isAutoDarkModel
{
    _isAutoDarkModel = isAutoDarkModel;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:isAutoDarkModel] forKey:kThemeAutoDarkModel];
    if (!isAutoDarkModel) {
        [self.timer invalidate];
        self.timer = nil;
    }
    else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        NSInteger second = [Tool timeStringToSecond:time];
        NSString *dayModelBegin = @"07:00:00";
        NSString *dayModelEnd = @"19:00:00";
        BOOL dark = YES;
        NSInteger nextUpdateTime = 0;
        if (second >= [Tool timeStringToSecond:dayModelBegin] && second < [Tool timeStringToSecond:dayModelEnd]) {
            dark = NO;
            nextUpdateTime = [Tool timeStringToSecond:dayModelEnd]-second;
        }
        else if (second < [Tool timeStringToSecond:dayModelBegin]){
            nextUpdateTime = [Tool timeStringToSecond:dayModelBegin] - second;
        }
        else{
            NSInteger oneday = 24*3600;
            nextUpdateTime = [Tool timeStringToSecond:dayModelBegin] - second + oneday;
        }
        self.isDarkTheme = dark;
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:nextUpdateTime target:self selector:@selector(typeChange:) userInfo:@(dark) repeats:NO];
    }
}

- (void)typeChange:(NSTimer*)timer
{
    BOOL userInfo = [timer.userInfo boolValue];
    self.isDarkTheme = !userInfo;
    self.isAutoDarkModel = YES;
}

- (UIFont *)defaultFontSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size+_textFont*2];
}

- (UIFont *)boldFontSize:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size+_textFont*2];
}

@end
