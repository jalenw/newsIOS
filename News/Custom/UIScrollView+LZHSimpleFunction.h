//
//  UIScrollView+LZHSimpleFunction.h
//  kuxing
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LZHSimpleFunction)


@property (nonatomic, strong) NSNumber *showOffset;

//下拉时调整顶部的View，在scrollViewDidScroll时调用
- (void)lzh_strtchHeaderView:(UIView *)headerView minHeight:(CGFloat)minHeight;


//在view出现时调用
- (void)lzh_addNotificationForKeyboard;
//在view消失时调用
- (void)lzh_removeNotifiacitonForKeyboard;

@end
