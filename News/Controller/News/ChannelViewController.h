//
//  ChannelViewController.h
//  News
//
//  Created by ye jiawei on 2017/11/1.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"

@interface ChannelViewController : BaseViewController

@property (nonatomic, strong) NSArray *like;
@property (nonatomic, strong) NSArray *dislike;

@property (nonatomic, strong) void (^sortFinish)(NSArray* like, NSArray* dislike);

@end
