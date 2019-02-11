//
//  NewsCell.h
//  News
//
//  Created by ye jiawei on 2017/11/2.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLabel.h"
#import "NewsObject.h"

#define kNotificationComment @"kNotificationComment"
#define kNotificationCollect @"kNotificationCollect"
#define kNotificationShare   @"kNotificationShare"
#define kNotificationLike    @"kNotificationLike"
#define kNotificationReport  @"kNotificationReport"

@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MyLabel *content;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet MyLabel *title;
@property (weak, nonatomic) IBOutlet UILabel *editor;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel3;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel4;
@property (weak, nonatomic) IBOutlet UILabel *adTime;

@property (strong, nonatomic) NewsObject *news;
- (IBAction)picTap:(UIButton *)sender;

+ (CGFloat)cellHeight:(NewsObject*)news;

@end
