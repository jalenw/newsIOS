//
//  AdvertisementWebViewController.m
//  zingchat
//
//  Created by noodle on 15/11/13.
//  Copyright (c) 2015年 Miju. All rights reserved.
//

#import "AdvertisementWebViewController.h"
@interface AdvertisementWebViewController ()<UIWebViewDelegate>
{
    NSString *tTitle;
    NSString *tContent;
    NSString *shareImgUrl;
    NSString *shareLink;
}
@end

@implementation AdvertisementWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = ScreenBounds;
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = 10;
    self.shareButton.layer.masksToBounds = YES;
    self.shareButton.layer.cornerRadius = 20;
    // Do any additional setup after loading the view from its nib.
}

- (void)initRequestUrl:(NSString*)url{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    webView.delegate = self;
    webView.backgroundColor = [UIColor clearColor];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:webView];
    [self.view addSubview:self.button];
    [self.view addSubview:self.shareButton];
    self.shareButton.hidden = YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
}
-(void)webView:(UIWebView*)webView DidFailLoadWithError:(NSError*)error
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(UIButton *)sender {
    self.webViewDismiss();
    [self.view removeFromSuperview];
}

@end
