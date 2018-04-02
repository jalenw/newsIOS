//
//  VoiceFileCacheManager.h
//  Miju
//
//  Created by Roger on 1/21/14.
//  Copyright (c) 2014 Miju. All rights reserved.
//

#import "FBFileCacheManager.h"
#import "FBCachedFile.h"

@interface VoiceFileCache : FBFileCacheManager

+ (instancetype)shareCache;
- (NSData*)getVoiceDataForUrl:(NSString*)url;//获取录音缓存

@end
