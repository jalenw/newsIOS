//
//  MyCommonCell.h
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLabel.h"

@interface MyCommonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet MyLabel *content;
@property (weak, nonatomic) IBOutlet UILabel *showTop;
@property (weak, nonatomic) IBOutlet UIView *baoView;
@property (weak, nonatomic) IBOutlet UILabel *name;

@property (strong, nonatomic) void(^buttonAct)(UIButton* sender);

@end
