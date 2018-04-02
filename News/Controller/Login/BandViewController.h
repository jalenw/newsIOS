//
//  BandViewController.h
//  News
//
//  Created by ye jiawei on 2017/11/28.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"

@interface BandViewController : BaseViewController

@property (nonatomic) BOOL isBandMail;
@property (nonatomic, strong) void (^bandPhone)(NSString* phone);

@end
