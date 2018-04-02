//
//  ButtonModel2.m
//  News
//
//  Created by ye jiawei on 2017/11/25.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ButtonModel2.h"
#import "UIImage+ChangeColor.h"

@implementation ButtonModel2

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
    UIImage *image = [self imageForState:UIControlStateNormal];
    if ([ThemeManager instance].isDarkTheme){
        [self setTitleColor:TextColor2Light forState:UIControlStateNormal];
        if (image) {
            [self setImage:[image imageWithColor:TextColor2Light] forState:UIControlStateNormal];
        }
    }
    else{
        [self setTitleColor:TextColor2 forState:UIControlStateNormal];
        if (image) {
            [self setImage:[image imageWithColor:TextColor2] forState:UIControlStateNormal];
        }
    }
}

@end
