//
//  UIView+XibLayout.h
//  yunwei
//
//  Created by ye jiawei on 2017/12/19.
//  Copyright © 2017年 ye. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UIView (XibLayout)
@property (nonatomic,assign)IBInspectable CGFloat borderWidth;
@property (nonatomic,strong)IBInspectable UIColor *borderColor;
@property (nonatomic,assign)IBInspectable CGFloat cornerRadius;

@end
