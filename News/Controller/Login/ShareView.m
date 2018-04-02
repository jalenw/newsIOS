//
//  ShareView.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ShareView.h"
#import <ShareSDK/ShareSDK.h>

@implementation ShareView

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

- (IBAction)share:(UIButton *)sender {
    [self removeFromSuperview];
    NSMutableDictionary *shareParams = [[NSMutableDictionary alloc]init];
    if (!self.shareUrl) {
        self.shareUrl = [NSString stringWithFormat:@"%@%@",base_url,@"wap/download/download.html"];
        self.shareUrl = @"http://www.24xuanbao.com";
    }
    if (!self.shareContent) {
        self.shareContent = @"早晚5分钟，阅览全球。24小时精选行业短新闻";
    }
    if (!self.shareTitle) {
        self.shareTitle = @"选报，精选您的新闻";
    }
    if (!self.images) {
        self.images = [UIImage imageNamed:@"share_logo"];
    }
    [shareParams SSDKSetupShareParamsByText:self.shareContent images:self.images url:[NSURL URLWithString:self.shareUrl] title:self.shareTitle type:SSDKContentTypeAuto];
    [ShareSDK share:sender.tag parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
                [AlertHelper showAlertWithTitle:@"分享成功!"];
                [MobClick event:self.shareType];
                NSLog(@"分享成功!");
                break;
            case SSDKResponseStateFail:
                [AlertHelper showAlertWithTitle:[NSString stringWithFormat:@"分享失败%@",error]];
                NSLog(@"分享失败%@",error);
                break;
            case SSDKResponseStateCancel:
                [AlertHelper showAlertWithTitle:@"分享已取消"];
                NSLog(@"分享已取消");
                break;
            default:
                break;
        }
    }];
}

@end
