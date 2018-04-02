//
//  InfomationViewController.h
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : int {
    infomationManager,
    infomationCheck,
} infomationType;

@interface InfomationViewController : BaseViewController

@property (nonatomic) infomationType type;

@end
