//
//  UINavigationItem+SXFixSpace.h
//  UINavigationItem-SXFixSpace
//
//  Created by charles on 2017/9/8.
//  Copyright © 2017年 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (SXFixSpace)
-(void)sx_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;
-(void)sx_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;
-(void)sx_setRightBarButtonItems:(NSArray *)rightBarButtonItems;
-(UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width;
@end
