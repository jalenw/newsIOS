//
//  AdvertisementWebViewController.h
//  zingchat
//
//  Created by noodle on 15/11/13.
//  Copyright (c) 2015年 Miju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvertisementWebViewController : UIViewController
- (IBAction)closeView:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) void (^webViewDismiss)(void);
- (void)initRequestUrl:(NSString*)url;
@end
