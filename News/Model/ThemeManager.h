//
//  ThemeManager.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

+ (instancetype)instance;
/** 是否是夜间模式 */
@property (nonatomic) BOOL isDarkTheme;

/**
 是否智能模式
 */
@property (nonatomic) BOOL isAutoDarkModel;
/**
 字体大小 -1小 0中 1大
 */
@property (nonatomic) BOOL isCloseAPNs;
@property (nonatomic) int textFont;

- (UIFont*)defaultFontSize:(CGFloat)size;
- (UIFont*)boldFontSize:(CGFloat)size;
- (void)loadModel;

@end
