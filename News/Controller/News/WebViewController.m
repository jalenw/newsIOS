//
//  WebViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/22.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "WebViewController.h"
#import "ShareView.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"网页";
    if (self.ad) {
        self.title = self.ad.info_title;
    }
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    self.webView.scrollView.bounces = NO;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"•••" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightAct) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

- (void)rightAct
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ShareView *view = [[NSBundle mainBundle]loadNibNamed:@"ShareView" owner:self options:nil][0];
        view.shareType = @"adShare";
        view.shareUrl = self.url;
        if (self.ad) {
            view.shareTitle = self.ad.info_title;
            view.shareContent = self.ad.info_content;
        }
        view.frame = ScreenBounds;
        [AppDelegateInstance.window addSubview:view];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"在浏览器打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    }];
    UIAlertAction *act3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [vc addAction:act1];
    [vc addAction:act2];
    [vc addAction:act3];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
