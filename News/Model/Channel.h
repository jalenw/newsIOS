//
//  Channel.h
//  News
//
//  Created by ye jiawei on 2017/11/23.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject
@property (nonatomic, strong) NSString *channel_content;
@property (nonatomic) int channel_id;
@property (nonatomic) BOOL hasUpdate;
@end
