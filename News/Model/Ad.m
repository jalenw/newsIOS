//
//  Ad.m
//  News
//
//  Created by ye jiawei on 2017/11/23.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "Ad.h"

@implementation Ad

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
        return @{@"pic":@"info_cover",
                 @"url":@"info_url",
                 @"text":@"info_content",
                 @"adID":@"info_id"
                 };
}

@end
