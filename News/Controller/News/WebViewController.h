//
//  WebViewController.h
//  News
//
//  Created by ye jiawei on 2017/11/22.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"
#import "Ad.h"

@interface WebViewController : BaseViewController

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) Ad *ad;

@end
