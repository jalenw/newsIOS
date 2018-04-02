//
//  Config.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define IosAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define ScreenBounds                    [UIScreen mainScreen].bounds
#define ScreenHeight                    [UIScreen mainScreen].bounds.size.height
#define ScreenWidth                     [UIScreen mainScreen].bounds.size.width

#define NavigationAndStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)


#define ThemeColor                RGB(223,48,49)
#define ThemeColorLight          RGB(144,43,43)

#define DayBackgroundColor        RGB(240,240,240)
#define LightBackgroundColor      RGB(32, 31, 36)

#define GrayColor                  RGB(240,240,240)
#define GrayColorLight             RGB(32, 31, 36)

#define WhiteColor                 RGB(255, 255, 255)
#define WhiteColorLight              RGB(42, 41, 47)

#define SplitLineColor                 RGB(229, 229, 229)
#define SplitLineColorLight              RGB(58, 57, 63)

#define cornerRadiusWidth 4

#define TextColor1           RGB(3,3,3)
#define TextColor1Light      RGB(173,174,179)

#define TextColor2        RGB(153,153,153)
#define TextColor2Light      RGB(107,108,116)

#define TextColor3        RGB(180,180,180)
#define TextColor3Light      RGB(92,93,98)

#define defaultSizeFont(s)  [[ThemeManager instance] defaultFontSize:s]
#define blodSizeFont(s)     [[ThemeManager instance] boldFontSize:s]

#endif /* Config_h */
