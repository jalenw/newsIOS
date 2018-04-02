//
//  AlertHelper.h
//  Ekeo2
//
//  Created by Roger on 13-8-29.
//  Copyright (c) 2013年 Ekeo. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface AlertHelper : NSObject
+ (void)showAlertWithDict:(NSDictionary*)dict;
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertWithTitle:(NSString*)title;
+(void)showAlertWithTitle:(NSString *)title duration:(NSTimeInterval)duration;
+ (void)showAlertWithDict:(NSDictionary*)dict controller:(UIViewController*)vc;
+ (BOOL)checkLogin:(UIViewController *)vc;
@end
