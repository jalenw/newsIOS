//
//  AppDelegate.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

#define base_url @"http://app.24xuanbao.com/" //测试环境:@"http://news.intexh.com/"  正式环境:@"http://app.24xuanbao.com/"
#define AppDelegateInstance ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define kNotificationModelColorChange  @"kNotificationModelColorChange"
#define kNotificationModelFontChange  @"kNotificationModelFontChange"
#define kNotificationModelAPNsChange  @"kNotificationModelAPNsChange"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *defaultUser;
@property (nonatomic) BOOL isReadingNews;
@property (strong,nonatomic) NSDictionary *remoteDict;//推送打开的信息
@property (strong,nonatomic) NSMutableArray *likeList;//已添加的频道列表
@property (strong, nonatomic) NSString *adUrl;//封面广告点击地址;

- (void)getUserInfo;
- (void)logout;
-(void)checkUpdate;
- (NSString*)returnLikeFilePath;
@end

