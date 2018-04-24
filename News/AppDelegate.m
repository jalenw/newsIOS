//
//  AppDelegate.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "AdvertisementViewController.h"
#import "AdvertisementWebViewController.h"
#import "BaiduVoice.h"
#import "User.h"
#import "LocationService.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"
//钉钉SDK头文件
#import <DTShareKit/DTOpenAPI.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>

//友盟
#import <UMCommon/UMCommon.h>           // 公共组件是所有友盟产品的基础组件，必选
#endif
#import "WebViewController.h"

@interface AppDelegate ()<AdvertisementViewDelegate,JPUSHRegisterDelegate>
{
    AdvertisementViewController *adVc;
    AdvertisementWebViewController *adWebVc;
    NSData *_deviceToken;
}
 @property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[LocationService sharedInstance]startUpdateLocation];
    
    [[[BaiduVoice alloc] init] configureSDK];
    [self showLoadView];
    [self customizeLayout];
    [[ThemeManager instance]loadModel];
    if (HTTPClientInstance.isLogin) {
        [self getUserInfo];
    }
    [self initSharePlatform];
    [self initAdvertisement];
    [self initYouMeng];

    //JPush
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerDeviceToken) name:kNotificationModelAPNsChange object:nil];
    [JPUSHService setupWithOption:launchOptions appKey:@"1b1f821017d82f1d6e874e0f"
                          channel:@"channel"
                 apsForProduction:YES];
    
    if (launchOptions) {
        self.remoteDict = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    [self setLikePlist];
    [self checkUpdate];
    
//    [JPUSHService setAlias:@"111111" completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//    } seq:0];
    return YES;
}

-(void)checkUpdate
{
    [HTTPClientInstance postMethod:@"act=news&op=base" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSString *newVersion = [[[data safeDictionaryForKey:@"datas"] safeStringForKey:@"app_ios_version"] stringByReplacingOccurrencesOfString:@"v" withString:@""];
            NSString *msg = [NSString stringWithFormat:@"你当前的版本是v%@，发现新版本v%@，请下载新版本使用？",IosAppVersion,newVersion];
            NSLog(@"线上版本%@ 现在版本%@",newVersion,IosAppVersion);
            if ([newVersion compare:IosAppVersion] == NSOrderedDescending) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"升级提示!" message:msg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1304186486?mt=8"]];
                    [[UIApplication sharedApplication]openURL:url];
                }];
                UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:act1];
                [alert addAction:act2];
                [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
            }else{
            }
        }
    }];
}

-(void)setLikePlist
{
    self.likeList = [[NSMutableArray alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:[self returnLikeFilePath]];
    if (result) {
        self.likeList = [NSMutableArray arrayWithContentsOfFile:[self returnLikeFilePath]];
    }
}

-(NSString*)returnLikeFilePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"like.plist"];
    return filename;
}

- (void)showLoadView
{
    ViewController *vc = [[ViewController alloc]init];
    self.window.rootViewController = vc;
}

- (void)showMainView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MainViewController *vc = [[MainViewController alloc]init];
        self.window.rootViewController = vc;
    });
}

- (void)registerDeviceToken
{
    if ([ThemeManager instance].isCloseAPNs) {
        [JPUSHService registerDeviceToken:nil];
    }
    else{
        [JPUSHService registerDeviceToken:_deviceToken];
    }
}

- (void)initYouMeng
{
    [UMConfigure initWithAppkey:@"5a422518f43e487ea3000018" channel:@"App Store"];
    [MobClick setScenarioType:E_UM_NORMAL];
}

- (void)customizeLayout
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    if ([ThemeManager instance].isDarkTheme){
        [[UINavigationBar appearance] setBackgroundImage:[Tool createImageWithColor:ThemeColorLight] forBarMetrics:UIBarMetricsDefault];
    }
    else{
        [[UINavigationBar appearance] setBackgroundImage:[Tool createImageWithColor:ThemeColor] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)logout
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kLogoutNotification" object:nil];
    [HTTPClientInstance clearLoginData];
    self.defaultUser = nil;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kNewsPlayList];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
    }];
    MainViewController *vc = [[MainViewController alloc]init];
    self.window.rootViewController = vc;
}

- (void)getUserInfo
{
    [HTTPClientInstance postMethod:@"act=newsuser" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            User *user = [User mj_objectWithKeyValues:dict];
            AppDelegateInstance.defaultUser = user;
        }
        else{
            [HTTPClientInstance clearLoginData];
            AppDelegateInstance.defaultUser = nil;
        }
    }];
}

#pragma mark - Advertisement
-(void)initAdvertisement
{
    [HTTPClientInstance postMethod:@"act=advertise" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (array.count > 0) {
                NSDictionary *dict = [array objectAtIndex:[self getRandomNumber:0 to:(int)(array.count-1)]];
                NSString *pic = [dict safeStringForKey:@"info_cover"];//advertise_address info_cover
                NSString *url = [dict safeStringForKey:@"info_url"];//advertise_url  info_url
                if (url.length>0) {
                    adVc = [[AdvertisementViewController alloc]init];
                    adVc.news_id = [dict safeStringForKey:@"info_id"];
                    adVc.advertisementViewDelegate = self;
                    [adVc setupAdvertisement:pic withUrl:url];
                    [self.window addSubview:adVc.view];
                }
                else{
                    [self showMainView];
                }
            }
            else{
                [self showMainView];
            }
        }
        else{
            [self showMainView];
        }
    }];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

-(void)AdvertisementClicked:(NSString *)url
{
    self.adUrl = url;
    [adVc.view removeFromSuperview];
    [self showMainView];
//    adWebVc = [[AdvertisementWebViewController alloc]init];
//    [adWebVc initRequestUrl:url];
//    __weak AppDelegate *weakSelf = self;
//    adWebVc.webViewDismiss = ^{
//        [weakSelf showMainView];
//    };
//    [self.window addSubview:adWebVc.view];
}

- (void)AdvertisementDismiss
{
    [self showMainView];
}

- (void)initSharePlatform
{
    [WXApi registerApp:@"wx0070a9a5bbfef3a0"];
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformSubTypeQZone),
                                        @(SSDKPlatformTypeDingTalk),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ)
                                        ]
                             onImport:^(SSDKPlatformType platformType) {
                                 switch (platformType)
                                 {
                                     case SSDKPlatformTypeWechat:
                                         [ShareSDKConnector connectWeChat:[WXApi class]];
                                         break;
                                     case SSDKPlatformTypeQQ:
                                         [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                                         break;
                                     case SSDKPlatformSubTypeQZone:
                                         [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                                         break;
                                     case SSDKPlatformTypeSinaWeibo:
                                         [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                                         break;
                                     case SSDKPlatformTypeDingTalk:
                                         [ShareSDKConnector connectDingTalk:[DTOpenAPI class]];
                                         break;
                                     default:
                                         break;
                                 }
                             } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                                 switch (platformType)
                                 {
                                     case SSDKPlatformTypeSinaWeibo:
                                         //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                                         [appInfo SSDKSetupSinaWeiboByAppKey:@"1842117588"
                                                                   appSecret:@"020d806d58bdb7910c51e2cf17dac89b"
                                                                 redirectUri:@""
                                                                    authType:SSDKAuthTypeBoth];
                                         break;
                                     case SSDKPlatformTypeWechat:
                                         [appInfo SSDKSetupWeChatByAppId:@"wx0070a9a5bbfef3a0"
                                                               appSecret:@"369b6270d50e1f88aa644db3c22ab9b0"];
                                         break;
                                     case SSDKPlatformTypeQQ:
                                         [appInfo SSDKSetupQQByAppId:@"1106550856"
                                                              appKey:@"8sVESEfPdSe1YZ79"
                                                            authType:SSDKAuthTypeBoth];
                                         break;
                                     case SSDKPlatformSubTypeQZone:
                                         [appInfo SSDKSetupQQByAppId:@"1106550856"
                                                              appKey:@"8sVESEfPdSe1YZ79"
                                                            authType:SSDKAuthTypeBoth];
                                         break;
                                     case SSDKPlatformTypeDingTalk:
                                         [appInfo SSDKSetupDingTalkByAppId:@"dingoajsobye2rnmv7iypm"];
                                         break;
                                     default:
                                         break;
                                 }
                             }];
}

#pragma mark - JPush
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    _deviceToken = deviceToken;
    [self registerDeviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    } // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
            if ([userInfo hasObjectForKey:@"news_id"]) {
                self.remoteDict = userInfo;
            }
        }
    } else {
        // Fallback on earlier versions
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.isReadingNews) {
        [self comeToBackgroundMode];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIApplication *app = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [app registerUserNotificationSettings:settings];
    app.applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)comeToBackgroundMode{
    //初始化一个后台任务BackgroundTask，这个后台任务的作用就是告诉系统当前app在后台有任务处理，需要时间
    UIApplication*  app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];//开启定时器 不断向系统请求后台任务执行的时间
    self.timer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
    [self.timer fire];
}

-(void)applyForMoreTime {
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 60) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)setIsReadingNews:(BOOL)isReadingNews
{
    _isReadingNews = isReadingNews;
    if (!isReadingNews) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

#pragma mark - updata
-(void)checkVersion
{
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/cn/lookup?id=1304186486"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:url];
    [SVProgressHUD show];
    [manager POST:@"" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"App.net Global Stream: %@", responseObject);
        NSString *newVersion;
        NSDictionary *dic = (NSDictionary*)responseObject;
        NSArray *resultArray = [dic objectForKey:@"results"];
        for (id config in resultArray) {
            newVersion = [config valueForKey:@"version"];
        }
        if (newVersion) {
            NSLog(@"通过AppStore获取的版本号是：%@",newVersion);
        }
        
        NSString *msg = [NSString stringWithFormat:@"你当前的版本是V%@，发现新版本V%@，请下载新版本使用？",IosAppVersion,newVersion];
        NSLog(@"线上版本%@ 现在版本%@",newVersion,IosAppVersion);
        if ([newVersion compare:IosAppVersion] == NSOrderedDescending) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"升级提示!" message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1304186486?mt=8"]];
                [[UIApplication sharedApplication]openURL:url];
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:act1];
            [alert addAction:act2];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }else{
            [AlertHelper showAlertWithTitle:@"当前已是最新版本"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [AlertHelper showAlertWithTitle:@"检查更新失败"];
    }];
}

@end
