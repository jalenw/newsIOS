//
//  ThemeView.m
//  News
//
//  Created by ye jiawei on 2017/11/24.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ThemeView.h"

@implementation ThemeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    [self themeColorChange];
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme){
        self.backgroundColor = ThemeColorLight;
    }
    else{
        self.backgroundColor = ThemeColor;
    }
}

@end
