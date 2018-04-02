//
//  BecomeEditorViewController.h
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"

@interface BecomeEditorViewController : BaseViewController

@property (nonatomic, strong) void (^realname)(NSString *realname, NSString *phone);

@end
