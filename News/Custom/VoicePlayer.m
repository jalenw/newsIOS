//
//  VoicePlayer.m
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import "VoicePlayer.h"
#import "VoiceFileCache.h"
#import "HTTPClient.h"

@interface VoicePlayer () <AVAudioPlayerDelegate>
@property AVAudioPlayer* player;
@property BOOL shouldDisableProximityMonitoring;
@end

@implementation VoicePlayer

+ (instancetype)sharedInstance
{
    static VoicePlayer* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[VoicePlayer alloc] init];
    });
    
    return _instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(udpateAudioSessionCategory)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}


- (void)playVoice:(NSString *)url
{
    [self stop];
    if (url.length == 0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:VoicePlayerStateFinishNotification object:nil userInfo:nil];
        return;
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSData* data = [[VoiceFileCache shareCache] getVoiceDataForUrl:url];
    if (!data)
    {
        [self stop];
        [[NSNotificationCenter defaultCenter]postNotificationName:VoicePlayerStateFinishNotification object:nil userInfo:nil];
        return;
    }
    
    NSError* error = nil;
    
    self.player.delegate = nil;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (error)
    {
        NSLog(@"player error %@", error);
        [self stop];
    }
    else
    {
        self.player.delegate = self;
        self.player.meteringEnabled = YES;
        [self.player prepareToPlay];
        [self.player play];
    }
}


- (void)stop
{
    if (self.player.isPlaying)
    {
        [self.player stop];
    }
    self.player.delegate = nil;
    self.player = nil;
}

- (void)pause
{
    if (self.player.isPlaying)
    {
        [self.player pause];
    }
}

- (void)play
{
    if (self.player.prepareToPlay) {
        [self.player play];
    }
}

- (void)stopTimer
{
    self.shouldDisableProximityMonitoring = YES;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (NSUInteger)currentPlayerPower
{
    if (self.player.isPlaying)
    {
        
//        float avgPower = [self.player averagePowerForChannel:0];
        NSUInteger powerIndex = 0;
//        if (avgPower < -30)
//            powerIndex = 1;
//        else if (avgPower >= -30 && avgPower < -15)
//            powerIndex = 2;
//        else if (avgPower >= -15)
//            powerIndex = 3;
        // 将动画效果由音量判断改为播放进度，0.5秒
        powerIndex = (NSUInteger)(ceil(self.player.currentTime * 2)) % 3;
        return powerIndex;
    }
    else
    {
        return 0;
    }
}

#pragma AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == self.player)
    {
        [self stopTimer];
        [[NSNotificationCenter defaultCenter]postNotificationName:VoicePlayerStateFinishNotification object:nil userInfo:nil];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self stopTimer];
    [self stop];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    [self stopTimer];
    [self stop];
}

+ (NSTimeInterval)durationForUrl:(NSString *)url
{
    NSTimeInterval duration = 0;
    NSData* data = [[VoiceFileCache shareCache] getVoiceDataForUrl:url];
    if (data)
    {
        AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        duration = player.duration;
    }
    return duration;
}

#pragma mark - sensor notification

- (void)udpateAudioSessionCategory
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
//        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        NSLog(@"Device is not close to user");
        
        if (self.shouldDisableProximityMonitoring)
        {
            self.shouldDisableProximityMonitoring = NO;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

@end
