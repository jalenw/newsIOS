//
//  AdCell.h
//  News
//
//  Created by ye jiawei on 2017/11/23.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ad.h"

@interface AdCell : UITableViewCell

@property (nonatomic, strong)Ad *ad;

+ (CGFloat)cellHeight;

@end
