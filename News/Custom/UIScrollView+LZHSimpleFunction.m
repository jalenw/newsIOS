//
//  UIScrollView+LZHSimpleFunction.m
//  kuxing
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIScrollView+LZHSimpleFunction.h"
#import "objc/runtime.h"

@implementation UIScrollView (LZHSimpleFunction)


- (id)showOffset
{
    id object = objc_getAssociatedObject(self, @"showOffset");
    
    return object;
}

- (void)setShowOffset:(id)tempObject
{
    [self willChangeValueForKey:@"tempObject"];
    objc_setAssociatedObject(self, @"showOffset", tempObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"tempObject"];
}

- (void)lzh_strtchHeaderView:(UIView *)headerView minHeight:(CGFloat)minHeight{
    CGFloat headerHeight = minHeight;
    
    if (self.contentOffset.y < 0) {
        headerView.top = self.contentOffset.y;
        headerView.height = headerHeight - self.contentOffset.y;
    }else{
        if (headerView.top != 0) {
            headerView.top = 0;
            headerView.height = headerHeight;
        }
    }
    
}



- (void)lzh_addNotificationForKeyboard{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lzh_inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)lzh_removeNotifiacitonForKeyboard{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)lzh_inputKeyboardWillShow:(NSNotification*)notification{
    UIView *responseView = [self getResponseWithView:self];
    if (responseView == nil) {
        return;
    }
    
    CGRect responseRect = [responseView.superview convertRect:responseView.frame toView:AppDelegateInstance.window];
    
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat responseBottomInScrollView = responseRect.origin.y+responseRect.size.height+10;
    
    CGFloat moveOffset = responseBottomInScrollView-keyboardRect.origin.y;
    
    if (moveOffset > 0) {
        CGPoint originOffset = self.contentOffset;
        originOffset.y += moveOffset;
        [self setContentOffset:originOffset animated:YES];
    }
}

- (void)keyboardWillDismiss:(NSNotification*)notification
{
    if (self.contentSize.height < self.height) {
        [self setContentOffset:CGPointMake(0, 0)];
    }
    else if (self.contentOffset.y > (self.contentSize.height-self.height)) {
        [self setContentOffset:CGPointMake(0, self.contentSize.height-self.height)];
    }
}

- (UIView*)getResponseWithView:(UIView*)pview{
    if (pview.isFirstResponder) {
        return pview;
    }
    for (UIView *subView in pview.subviews) {
        UIView *subsubView = [self getResponseWithView:subView];
        if (subsubView) {
            return subsubView;
        }
    }
    return nil;
}

@end
