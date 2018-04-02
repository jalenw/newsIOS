//
//  MyCommonCell.m
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "MyCommonCell.h"

@implementation MyCommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.content setVerticalAlignment:VerticalAlignmentTop];
    self.showTop.textColor = ThemeColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonPress:(UIButton *)sender {
    if (self.buttonAct) {
        self.buttonAct(sender);
    }
}

@end
