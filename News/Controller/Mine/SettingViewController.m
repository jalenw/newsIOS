//
//  SettingViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel1;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel2;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    [self refreshDiskSize];
    self.logoutBtn.hidden = !HTTPClientInstance.isLogin;
    self.versionLabel1.text = [NSString stringWithFormat:@"v%@",IosAppVersion];
    self.versionLabel2.text = [NSString stringWithFormat:@"v%@",IosAppVersion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme) {
        [self.logoutBtn setTitleColor:ThemeColorLight forState:UIControlStateNormal];
        self.logoutBtn.backgroundColor = WhiteColorLight;
    }
    else
    {
        [self.logoutBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
        self.logoutBtn.backgroundColor = WhiteColor;
    }
}

- (void)refreshDiskSize
{
    long long size = [[SDImageCache sharedImageCache] getSize];
    float mbsize = size/1024.0f/1024.0f;
    self.cacheLabel.text = [NSString stringWithFormat:@"%.2fMB",mbsize];
}
- (IBAction)logout:(UIButton *)sender {
    [AppDelegateInstance logout];
}
- (IBAction)cleanCache:(UIButton *)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"是否清除缓存" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MobClick event:@"cleanCache"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kNewsPlayList];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [self refreshDiskSize];
        }];
    }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [vc addAction:ac1];
    [vc addAction:ac2];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)checkVersion:(UIButton *)sender {
    [MobClick event:@"update"];
    [AppDelegateInstance checkUpdate];
}
- (IBAction)aboutUs:(UIButton *)sender {
    AboutViewController *vc = [[AboutViewController alloc]init];
    vc.isAbout = YES;
    [MobClick event:@"aboutUs"];
    [self.navigationController pushViewController:vc animated:YES];
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
