//
//  Comment.h
//  News
//
//  Created by ye jiawei on 2017/11/17.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic) int64_t news_id;
@property (nonatomic) int64_t pid;
@property (nonatomic) int64_t comment_id;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * sender;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic) int likeNum;
@property (nonatomic) NSInteger sender_id;
@property (nonatomic) BOOL hasLike;
@property (nonatomic) double createTime;
@property (nonatomic, strong) NSArray<Comment *> * subComment;


@end
