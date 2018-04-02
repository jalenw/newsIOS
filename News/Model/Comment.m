//
//  Comment.m
//  News
//
//  Created by ye jiawei on 2017/11/17.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (NSComparisonResult)compare:(Comment*)other
{
    return self.createTime > other.createTime;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"news_id":@"reply_nid",
             @"comment_id":@"reply_id",
             @"pid":@"reply_parentid",
             @"likeNum":@"reply_likenum",
             @"content":@"reply_content",
             @"createTime":@"reply_createtime",
             @"subComment":@"sonlist",
             @"sender":@"reply_unickname",
             @"avatar":@"reply_uavatar",
             @"hasLike":@"reply_uislike"
             };
}

@end
