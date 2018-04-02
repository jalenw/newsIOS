//
//  TextFieldModel1.m
//  News
//
//  Created by ye jiawei on 2017/11/25.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "TextFieldModel1.h"

@implementation TextFieldModel1

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
        self.textColor = TextColor1Light;
        if (self.placeholder.length>0) {
            NSMutableAttributedString * attributedStr =[[NSMutableAttributedString alloc]initWithString:self.placeholder];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:TextColor3Light range:NSMakeRange(0,attributedStr.length)];
            self.attributedPlaceholder = attributedStr;
        }
    }
    else{
        self.textColor = TextColor1;
        if (self.placeholder.length>0) {
            NSMutableAttributedString * attributedStr =[[NSMutableAttributedString alloc]initWithString:self.placeholder];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:TextColor3 range:NSMakeRange(0,attributedStr.length)];
            self.attributedPlaceholder = attributedStr;
        }
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if ([ThemeManager instance].isDarkTheme){
        if (placeholder>0) {
            NSMutableAttributedString * attributedStr =[[NSMutableAttributedString alloc]initWithString:placeholder];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:TextColor3Light range:NSMakeRange(0,attributedStr.length)];
            self.attributedPlaceholder = attributedStr;
        }
    }
    else{
        if (placeholder>0) {
            NSMutableAttributedString * attributedStr =[[NSMutableAttributedString alloc]initWithString:placeholder];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:TextColor3 range:NSMakeRange(0,attributedStr.length)];
            self.attributedPlaceholder = attributedStr;
        }
    }
}

@end
