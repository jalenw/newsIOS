//
//  ListenNews.m
//  News
//
//  Created by ye jiawei on 2017/12/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ListenNews.h"
#import "NewsObject.h"
#import "VoicePlayer.h"
#import "VoiceDownloader.h"
#import "BDSSpeechSynthesizer.h"

@interface ListenNews()<BDSSpeechSynthesizerDelegate>
{
    BOOL _isPlayAd;
    BOOL _isLoading;
    NSInteger _playCount;
}
@property (nonatomic, strong) NSMutableArray *playList;
@property (nonatomic, strong) NSDictionary *channel;
@property (nonatomic) int playIndex;

@end

@implementation ListenNews

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishAdVoice) name:VoicePlayerStateFinishNotification object:nil];
        [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
        self.playList = [[NSMutableArray alloc]init];
        _playCount = -1;
    }
    return self;
}

- (void)setCurrentChannel:(NSString *)currentChannel listenList:(NSArray *)list topNewsTime:(double)topNewsTime
{
    _currentChannel = currentChannel;
    _topNewsTime = topNewsTime;
    for (NSDictionary *dict in self.likeList) {
        if ([[dict safeStringForKey:@"channel_id"] isEqualToString:self.currentChannel]) {
            self.channel = dict;
        }
    }
    _playIndex = 0;
    [self.playList removeAllObjects];
    for (NewsObject *object in list) {
//        if ([object.news_showtime doubleValue] < topNewsTime) {
            [self.playList addObject:object];
//        }
    }
    [self play];
}

- (void)getPlayList
{
    _isLoading = YES;
    NSDictionary *params = @{@"channel_id":[self.channel safeStringForKey:@"channel_id"],@"time":@(_topNewsTime)};
    [HTTPClientInstance postMethod:@"act=news" params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        _isLoading = NO;
        if (code == 200) {
            [self.playList removeAllObjects];
            _playIndex = 0;
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSArray *news = [dict safeArrayForKey:@"news"];
            NSArray *newsArr = [NewsObject mj_objectArrayWithKeyValuesArray:news];
            [self.playList addObjectsFromArray:newsArr];
            [self play];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}



- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    if (videoUrl.length == 0) {
        return;
    }
    [[VoiceDownloader sharedInstance]downloadVoiceForUrl:self.videoUrl];
}

- (void)play{
    if (_isLoading) {
        return;
    }
    [self startRead];
}

- (void)pause{
    if (_isPlayAd) {
        [[VoicePlayer sharedInstance]pause];
    }
    else{
        [[BDSSpeechSynthesizer sharedInstance]pause];
    }
}

- (void)stop{
    [[VoicePlayer sharedInstance] stop];
    [[BDSSpeechSynthesizer sharedInstance] cancel];
}

- (void)startRead{
    AppDelegateInstance.isReadingNews = YES;
    BDSSynthesizerStatus readStatus = [[BDSSpeechSynthesizer sharedInstance] synthesizerStatus];
    switch (readStatus) {
        case BDS_SYNTHESIZER_STATUS_PAUSED:
            [[BDSSpeechSynthesizer sharedInstance]resume];
            break;
        default:
        {
            NSArray *array = self.playList;
            if (array.count > _playIndex) {
                if ([self shouldAddAD] && self.videoUrl) {
                    [self.playList insertObject:self.videoUrl atIndex:_playIndex];
                    array = self.playList;
                }
                if ([array[_playIndex] isKindOfClass:[NSString class]]) {
                    [self playAdVoice];
                }
                else{
                    NewsObject *news = array[_playIndex];
//                    if (![Tool isTodayTime:[news.news_showtime doubleValue]] && !news.news_top) {
//                        [self checkChannel];
//                    }
//                    else
//                    if ([Tool canPlayNew:[news.news_id stringValue]]) {
                    NSString *readString = [NSString stringWithFormat:@"%@,%@",news.news_title,[news.news_content componentsSeparatedByString:@"（消息来源："][0]];
                        NSError *err = nil;
                        [[BDSSpeechSynthesizer sharedInstance]speakSentence:readString withError:&err];
                    if (err) {
                        [self startRead];
                    }
//                    }
//                    else{
//                        _playIndex++;
//                        [self startRead];
//                    }
                }
            }
            else{
                [self checkChannel];
            }
        }
            break;
    }
}

- (void)playAdVoice
{
    if (_isPlayAd) {
        [[VoicePlayer sharedInstance] play];
    }
    else{
        _isPlayAd = YES;
        [[VoicePlayer sharedInstance] playVoice:self.videoUrl];
    }
}

- (void)finishAdVoice
{
    _isPlayAd = NO;
    _playCount++;
    _playIndex++;
    [self startRead];
}

- (void)synthesizerSpeechEndSentence:(NSInteger)SpeakSentence
{
    _playIndex++;
    _playCount++;
    [self startRead];
}

- (BOOL)shouldAddAD
{
    if (_playCount == 4) {
        return YES;
    }
    else if (_playCount == 14){
        return YES;
    }
    else if ( (_playCount-15) % 20 == 19){
        return YES;
    }
    return NO;
}

- (void)checkChannel
{
    NewsObject *object = [self.playList lastObject];
    if ([Tool isTodayTime:[object.news_showtime doubleValue]]) {
        _topNewsTime = [object.news_showtime doubleValue]-1;
        [self getPlayList];
    }
    else{
        AppDelegateInstance.isReadingNews = NO;
        _playIndex = 0;
        self.playFinish(YES);
    }
    return;
    if ([self.currentChannel isEqualToString:@"0"]) {
        for (int i = 0; i < self.likeList.count; i++) {
            NSDictionary *dict = self.likeList[i];
            if ([dict isEqual:self.channel]) {
                int next = i+1;
                if (self.likeList.count>next) {
                    self.channel = self.likeList[next];
                    _topNewsTime = 0;
                    [self getPlayList];
                }
                break;
            }
        }
    }
    else{
        AppDelegateInstance.isReadingNews = NO;
        _playIndex = 0;
        self.playFinish(YES);
    }
}

@end
