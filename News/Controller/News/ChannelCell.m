//
//  ChannelCell.m
//  News
//
//  Created by ye jiawei on 2017/11/2.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ChannelCell.h"
#import "LabelModel1.h"
#import "WhiteView.h"
#import "UIImage+ChangeColor.h"
#import "GrayView.h"

@implementation ChannelCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshView) name:kNotificationModelFontChange object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshView) name:kNotificationModelColorChange object:nil];
        UIView *whiteView = [[WhiteView alloc]initWithFrame:self.bounds];
        whiteView.autoresizingMask = UIViewAutoresizingFlexibleCenter | UIViewAutoresizingFlexibleSize;
        [self addSubview:whiteView];
        self.label = [[LabelModel1 alloc]initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleCenter | UIViewAutoresizingFlexibleSize;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius = cornerRadiusWidth;
        self.layer.borderWidth = 0.5;
        [self refreshView];
        [self addSubview:self.label];
        CGFloat imageWidth = 8;
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
        image.image = [[UIImage imageNamed:@"close"] imageWithColor:ThemeColor];
        self.closeImage = [[GrayView alloc]initWithFrame:CGRectMake(self.width-imageWidth, 0, imageWidth, imageWidth)];
        [self.closeImage addSubview:image];
        [self addSubview:self.closeImage];        
    }
    return self;
}

- (void)refreshView
{
    if ([ThemeManager instance].isDarkTheme){
        self.layer.borderColor = TextColor1Light.CGColor;
    }
    else{
        self.layer.borderColor = TextColor1.CGColor;
    }
}

@end
