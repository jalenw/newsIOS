//
//  NewsObj.h
//  News
//
//  Created by ye jiawei on 2017/11/16.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ad;

@interface NewsObject : NSObject
@property (nonatomic) BOOL isSpread;

@property (nonatomic, strong) NSString *news_content;
@property (nonatomic) NSInteger news_commentnum;
@property (nonatomic, strong) NSNumber *news_id;
@property (nonatomic, strong) NSString *news_uname;
@property (nonatomic, strong) NSString *news_title;
@property (nonatomic, strong) NSNumber *news_createtime;
@property (nonatomic) NSInteger news_channelid;
@property (nonatomic, strong) NSString *news_channelcontent;
@property (nonatomic, strong) NSNumber *news_showtime;
@property (nonatomic, strong) NSString *news_date;
@property (nonatomic, strong) NSString *news_pic;
@property (nonatomic) BOOL news_red;
@property (nonatomic) BOOL collected;
@property (nonatomic) BOOL likenew;
@property (nonatomic) BOOL news_top;

@property (nonatomic, strong) Ad *ad;
@property (nonatomic, strong) Ad *textAD;

@end
