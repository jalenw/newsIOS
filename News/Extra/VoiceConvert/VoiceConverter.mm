//
//  VoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (NSString*)wavPathForAmrPath:(NSString*)_amrPath
{
    return [[_amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
}

+ (NSString*)amrPathForWavPath:(NSString*)_wavPath
{
    return [[_wavPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
}

+ (BOOL)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
    
    
@end
