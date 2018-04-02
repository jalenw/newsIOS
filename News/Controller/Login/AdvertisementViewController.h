//
//  AdvertisementViewController.h
//  zingchat
//
//  Created by noodle on 15/11/13.
//  Copyright (c) 2015年 Miju. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AdvertisementViewDelegate <NSObject>
- (void)AdvertisementDismiss;
- (void)AdvertisementClicked:(NSString*)url;
@end
@interface AdvertisementViewController : UIViewController
@property (weak)id <AdvertisementViewDelegate> advertisementViewDelegate;
@property (strong,nonatomic)NSString *news_id;
@property (weak, nonatomic) IBOutlet UIImageView *tipImg;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong,nonatomic) NSString *url;
-(void)setupAdvertisement:(NSString*)pic withUrl:(NSString*)url;
@end
