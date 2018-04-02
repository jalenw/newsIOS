//
//  LoginView.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "LoginView.h"
#import "User.h"
#import <ShareSDK/ShareSDK.h>
#import "LoginViewController.h"

@implementation LoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)close:(UIButton *)sender {
    [self removeFromSuperview];
}
- (IBAction)login:(UIButton *)sender {
    [self removeFromSuperview];
    if (self.loginTpye) {
        self.loginTpye(sender.tag);
    }
    else{
        switch (sender.tag) {
            case 0:
                [self loginWithShareType:SSDKPlatformTypeWechat];
                break;
            case 1:
                [self loginWithShareType:SSDKPlatformSubTypeQZone];
                break;
            case 2:
            {
                UITabBarController *tabVc = AppDelegateInstance.window.rootViewController;
                UINavigationController *naVc = tabVc.selectedViewController;
                LoginViewController *vc = [[LoginViewController alloc]init];
                if (!self.naviVc) {
                    [naVc pushViewController:vc animated:YES];
                }
                else{
                    [self.naviVc pushViewController:vc animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}


- (void)loginWithShareType:(SSDKPlatformType)shareType{
    [ShareSDK cancelAuthorize:shareType];
    [ShareSDK getUserInfo:shareType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            [self loginWithUserInfo:user];
        }else if (state == SSDKResponseStateFail || state == SSDKResponseStateCancel){
            
            if (shareType == SSDKPlatformSubTypeQZone) {
                //                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"QQ登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                //                [alertView show];
                [AlertHelper showAlertWithTitle:@"QQ登陆失败"];
            }else if (shareType == SSDKPlatformTypeWechat) {
                [AlertHelper showAlertWithTitle:@"微信登录失败"];
                
            }else if (shareType == SSDKPlatformTypeSinaWeibo){
                [AlertHelper showAlertWithTitle:@"微博登录失败"];
            }
        }
    }];
}

- (void)loginWithUserInfo:(SSDKUser*)userInfo{
    NSString *method = nil;
    NSString *name = userInfo.nickname;
    SSDKCredential *credential = userInfo.credential;
    NSString* openId = [credential uid];
    NSString *icon = userInfo.icon;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:icon forKey:@"headimgurl"];
    [params setValue:name forKey:@"nickname"];
    [params setValue:openId forKey:@"openid"];
    if (userInfo.platformType == SSDKPlatformSubTypeQZone) {
        method = @"act=connect&op=loginByQq";
    }
    else if (userInfo.platformType == SSDKPlatformTypeWechat){
        method = @"act=connect&op=loginByWeixin";
        NSDictionary *rawData = [credential rawData];
        NSString *unionid = [rawData safeStringForKey:@"unionid"];
        [params setValue:unionid forKey:@"unionid"];
    }
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:method params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [HTTPClientInstance setUid:[dict safeStringForKey:@"member_id"] token:[dict safeStringForKey:@"key"]];
            User *user = [User mj_objectWithKeyValues:dict];
            AppDelegateInstance.defaultUser = user;
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}


@end
