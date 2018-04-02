//
//  LoginView.h
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView

@property (nonatomic, strong) void (^loginTpye)(NSInteger type);
@property (nonatomic, strong) UINavigationController *naviVc;
@end
