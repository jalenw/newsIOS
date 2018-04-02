//
//  MainViewController.m
//  SinaWeibo
//
//  Created by user on 15/10/13.
//  Copyright © 2015年 ZT. All rights reserved.
//

#import "MainViewController.h"
#import "ZTNavigationController.h"
#import "NewsViewController.h"
#import "PostViewController.h"
#import "MyViewController.h"

@interface MainViewController () <UITabBarControllerDelegate>
{
    NSInteger _unreadMessageCount;
}

@end

@implementation MainViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加子控制器
    self.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    
    
    NewsViewController *news = [[NewsViewController alloc] init];
    PostViewController *post = [[PostViewController alloc] init];
    post.simpleModel = YES;
    post.isNavi = YES;
    MyViewController *home = [[MyViewController alloc] init];
    [self addChildVc:news title:@"新闻" image:@"tabbar_news" selectedImage:@"tabbar_news_sel"];
    [self addChildVc:post title:@"爆料" image:@"tabbar_post" selectedImage:@"tabbar_post_sel"];
    [self addChildVc:home title:@"我的" image:@"tabbar_mine" selectedImage:@"tabbar_mine_sel"];
    [self setUnreadMsgCount:_unreadMessageCount];
    [self themeColorChange];
    
}

- (void)refreshUnreadCount{
    
    [self setUnreadMsgCount:_unreadMessageCount];
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme) {
        self.tabBar.backgroundImage = [Tool createImageWithColor:RGB(29,29,31)];
    }
    else{
        self.tabBar.backgroundImage = [Tool createImageWithColor:[UIColor whiteColor]];
    }
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置子控制器的文字(可以设置tabBar和navigationBar的文字)
    childVc.title = title;
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor} forState:UIControlStateSelected];
    
    // 设置子控制器的tabBarItem图片
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 禁用图片渲染
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    childVc.view.backgroundColor = [UIColor blackColor]; // 这句代码会自动加载主页，消息，发现，我四个控制器的view，但是view要在我们用的时候去提前加载
    
    // 为子控制器包装导航控制器
    ZTNavigationController *navigationVc = [[ZTNavigationController alloc] initWithRootViewController:childVc];
    // 添加子控制器
    [self addChildViewController:navigationVc];
}

-(void)setUnreadMsgCount:(NSInteger)unreadMessageCount
{
//    if (unreadMessageCount==0) {
//        ((ZTNavigationController*)self.childViewControllers[3]).tabBarItem.badgeValue = nil;
//    }
//    else
//    ((ZTNavigationController*)self.childViewControllers[3]).tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadMessageCount];
}

- (void)didReceiveMessage:(NSNotification*)notification
{
    _unreadMessageCount++;
    [self setUnreadMsgCount:_unreadMessageCount];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}


@end
