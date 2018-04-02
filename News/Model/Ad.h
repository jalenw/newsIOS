//
//  Ad.h
//  News
//
//  Created by ye jiawei on 2017/11/23.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ad : NSObject

@property (nonatomic, strong) NSString *pic;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) int adID;
@property (nonatomic, strong) NSString *info_title;
@property (nonatomic, strong) NSString *info_content;

@end
