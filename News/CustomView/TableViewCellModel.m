//
//  TableViewCellModel.m
//  News
//
//  Created by ye jiawei on 2017/11/24.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "TableViewCellModel.h"

@implementation TableViewCellModel

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    [self themeColorChange];
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme){
        self.backgroundColor = SplitLineColorLight;
        self.contentView.backgroundColor = SplitLineColorLight;
    }
    else{
        self.backgroundColor = SplitLineColor;
        self.contentView.backgroundColor = SplitLineColor;
    }
}
@end
