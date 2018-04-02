//
//  BaseViewController.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeFontChange) name:kNotificationModelFontChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    [self themeColorChange];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme){
        [self.navigationController.navigationBar setBackgroundImage:[Tool createImageWithColor:ThemeColorLight] forBarMetrics:UIBarMetricsDefault];
        self.view.backgroundColor = LightBackgroundColor;
    }
    else{
        [self.navigationController.navigationBar setBackgroundImage:[Tool createImageWithColor:ThemeColor] forBarMetrics:UIBarMetricsDefault];
        self.view.backgroundColor = DayBackgroundColor;
    }
}

- (void)themeFontChange
{
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
