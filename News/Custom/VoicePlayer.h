//
//  VoicePlayer.h
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#define VoicePlayerStateFinishNotification       @"VoicePlayerStateFinishNotification"

@interface VoicePlayer : NSObject
@property (readonly) AVAudioPlayer* player;

+ (instancetype)sharedInstance;

- (void)playVoice:(NSString *)url;//播放网络音频

- (void)stop;//停止播放
- (void)play;
- (void)pause;
- (NSUInteger)currentPlayerPower;//声音音量

+ (NSTimeInterval)durationForUrl:(NSString*)url;//声音时长

@end
