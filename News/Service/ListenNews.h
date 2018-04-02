//
//  ListenNews.h
//  News
//
//  Created by ye jiawei on 2017/12/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListenNews : NSObject

@property (nonatomic, strong) NSString *currentChannel;
@property (nonatomic, strong) NSArray *likeList;
@property (nonatomic) double topNewsTime;
@property (nonatomic, strong) NSString *videoUrl;

@property (nonatomic, strong) void (^playFinish)(BOOL finish);
@property (nonatomic, strong) void (^getVideoAd)(void);

- (void)setCurrentChannel:(NSString *)currentChannel listenList:(NSArray*)list topNewsTime:(double)topNewsTime;
- (void)play;
- (void)stop;
- (void)pause;

@end
