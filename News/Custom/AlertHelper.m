//
//  AlertHelper.m
//  Ekeo2
//
//  Created by Roger on 13-8-29.
//  Copyright (c) 2013年 Ekeo. All rights reserved.
//

#import "AlertHelper.h"
#import "SVProgressHUD.h"
#import "LoginView.h"

@implementation AlertHelper

+ (NSMutableArray*)alertQueue
{
    static NSMutableArray *_alertQueueInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _alertQueueInstance = [[NSMutableArray alloc] init];
    });
    
    return _alertQueueInstance;
}

+ (void)showAlertWithDict:(NSDictionary *)dict
{
    NSDictionary *datas = [dict safeDictionaryForKey:@"datas"];
    int code = [dict safeIntForKey:@"code"];
    if (code == 404) {
        [HTTPClientInstance clearLoginData];
        AppDelegateInstance.defaultUser = nil;
        UITabBarController *tabVc = (UITabBarController*)AppDelegateInstance.window.rootViewController;
        UINavigationController *naVc = tabVc.selectedViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录再进行操作" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            LoginView *view = [[NSBundle mainBundle]loadNibNamed:@"LoginView" owner:self options:nil][0];
            view.frame = ScreenBounds;
            [AppDelegateInstance.window addSubview:view];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:act1];
        [alert addAction:act2];
        [naVc presentViewController:alert animated:YES completion:nil];
    }
    else{
        NSString *error = [datas safeStringForKey:@"error"];
        [AlertHelper showAlertWithTitle:error];
    }
}

+ (void)showAlertWithDict:(NSDictionary *)dict controller:(UIViewController *)vc
{
    NSDictionary *datas = [dict safeDictionaryForKey:@"datas"];
    int code = [dict safeIntForKey:@"code"];
    if (code == 404) {
        [HTTPClientInstance clearLoginData];
        AppDelegateInstance.defaultUser = nil;
        UITabBarController *tabVc = (UITabBarController*)AppDelegateInstance.window.rootViewController;
        UINavigationController *naVc = tabVc.selectedViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录再进行操作" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [vc.view removeFromSuperview];
            LoginView *view = [[NSBundle mainBundle]loadNibNamed:@"LoginView" owner:self options:nil][0];
            view.frame = ScreenBounds;
            [AppDelegateInstance.window addSubview:view];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:act1];
        [alert addAction:act2];
        [naVc presentViewController:alert animated:YES completion:nil];
    }
    else{
        NSString *error = [datas safeStringForKey:@"error"];
        [AlertHelper showAlertWithTitle:error];
    }
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    if (message == nil)
    {
        [self showAlertWithTitle:title];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

+ (void)showAlertWithTitle:(NSString*)title
{
    if (title && title.length > 0) {
        [SVProgressHUD showImage:nil status:title];
    }else{
        [SVProgressHUD showImage:nil status:@"网络异常"];
    }
}

+(void)showAlertWithTitle:(NSString *)title duration:(NSTimeInterval)duration
{
    [SVProgressHUD showImage:nil status:title duration:duration];
}

+ (BOOL)checkLogin:(UIViewController *)vc
{
    if (!HTTPClientInstance.isLogin) {
        UITabBarController *tabVc = (UITabBarController*)AppDelegateInstance.window.rootViewController;
        UINavigationController *naVc = tabVc.selectedViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录再进行操作" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [vc.view removeFromSuperview];
            LoginView *view = [[NSBundle mainBundle]loadNibNamed:@"LoginView" owner:self options:nil][0];
            view.frame = ScreenBounds;
            [AppDelegateInstance.window addSubview:view];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:act1];
        [alert addAction:act2];
        [naVc presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

@end
