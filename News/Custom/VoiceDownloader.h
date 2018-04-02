//
//  VoiceDownloader.h
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VoiceMessageDownloadFinishNotification @"VoiceMessageDownloadFinishNotification"

@interface VoiceDownloader : NSObject
+ (instancetype)sharedInstance;//获取单例
- (void)downloadVoiceForUrl:(NSString*)url;//下载录音
@end
