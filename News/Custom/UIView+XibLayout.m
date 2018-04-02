//
//  UIView+XibLayout.m
//  yunwei
//
//  Created by ye jiawei on 2017/12/19.
//  Copyright © 2017年 ye. All rights reserved.
//

#import "UIView+XibLayout.h"

@implementation UIView (XibLayout)
- (void)setBorderWidth:(CGFloat)borderWidth
{
    if(borderWidth <0) return;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius >0;
}
@end
