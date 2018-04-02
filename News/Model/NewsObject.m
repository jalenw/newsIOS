//
//  NewsObj.m
//  News
//
//  Created by ye jiawei on 2017/11/16.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "NewsObject.h"

@implementation NewsObject

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"news_content":@"new_content",
             @"news_commentnum":@"new_commentnum",
             @"news_id":@"new_id",
             @"news_uname":@"new_uname",
             @"news_title":@"new_title",
             @"news_createtime":@"new_createtime",
             @"news_channelid":@"new_channelid",
             @"news_showtime":@"sorttime",
             @"news_date":@"sorttime",
             @"news_channelcontent":@"news_channelcontent",
             @"news_pic":@"new_pic",
             @"news_red":@"new_red",
             @"news_top":@"new_top"
             };
}

- (NSString *)extracted:(double)time {
    return [Tool timeToChineseCalendar:time];
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"news_date"]) {
        double time = [oldValue doubleValue];
        return [self extracted:time];
    }
    return oldValue;
}

@end
