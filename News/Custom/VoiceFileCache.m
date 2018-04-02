//
//  VoiceFileCacheManager.m
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import "VoiceFileCache.h"
#import "VoiceConverter.h"
@implementation VoiceFileCache

+ (instancetype)shareCache
{
    static VoiceFileCache* _shareCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"Voice"];
        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _shareCache = [[VoiceFileCache alloc] initWithPath:path size:100]; //100Mb
    });
    
    return _shareCache;
}

- (NSData*)getVoiceDataForUrl:(NSString *)url
{
    FBCachedFile* wavFile = [self cachedFileForURL:[NSURL URLWithString:url]];
    if (wavFile)
    {
        return wavFile.data;
    }
    else
    {
        FBCachedFile* amrFile = [self cachedFileForURL:[NSURL URLWithString:url]];
        if (amrFile)
        {
            NSString* wavFilePath = [self cachedFilePathForURL:[NSURL URLWithString:url]];
            if ([VoiceConverter amrToWav:amrFile.path wavSavePath:wavFilePath])
            {
                FBCachedFile* wavFile = [self cachedFileForURL:[NSURL URLWithString:url]];
                return wavFile.data;
            }
        }
    }
    
    return nil;
}

@end
