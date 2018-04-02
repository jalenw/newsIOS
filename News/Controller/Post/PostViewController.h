//
//  PostViewController.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BaseViewController.h"
#import "NewsObject.h"

@interface PostViewController : BaseViewController

@property (nonatomic) BOOL isNavi;
@property (nonatomic) BOOL simpleModel;
@property (nonatomic) BOOL isCheck;
@property (nonatomic, strong) NSDictionary *news;

@end
