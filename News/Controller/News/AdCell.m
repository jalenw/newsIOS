//
//  AdCell.m
//  News
//
//  Created by ye jiawei on 2017/11/23.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "AdCell.h"

@interface AdCell()
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@end

@implementation AdCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    [self.adImage sd_setImageWithURL:[NSURL URLWithString:ad.pic]];
}

+ (CGFloat)cellHeight
{
    return 140;
}

@end
