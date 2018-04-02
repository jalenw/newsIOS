//
//  VoiceDownloader.m
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import "VoiceDownloader.h"
#import "VoiceConverter.h"
#import "VoiceFileCache.h"
#import "BDMultiDownloader.h"

@implementation VoiceDownloader

+ (instancetype)sharedInstance
{
    static VoiceDownloader* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[VoiceDownloader alloc] init];
    });
    
    return _instance;
}

- (void)downloadVoiceForUrl:(NSString *)url
{
    if (![[VoiceFileCache shareCache] cachedFileForURL:[NSURL URLWithString:url]])
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:url])
        {
            [[BDMultiDownloader shared] queueRequest:url
                                          completion:^(NSData *data){
                                              if  (data == nil){
                                                  NSLog(@"download data nil");
                                                  return;
                                              }
                                              
                                              FBCachedFile* amrFile = [[VoiceFileCache shareCache] putData:data forURL:[NSURL URLWithString:url]];
                                              
                                              NSString* wavFilePath = [[VoiceFileCache shareCache] cachedFilePathForURL:[NSURL URLWithString:url]];
                                              if ([VoiceConverter amrToWav:amrFile.path wavSavePath:wavFilePath])
                                              {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:VoiceMessageDownloadFinishNotification object:url];
                                              }
                                          }];
        }
    }
}
@end
