//
//  Tool.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNewsPlayList @"kNewsPlayList"

@interface Tool : NSObject

+(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize string:(NSString*)string;
+(UIImage*)createImageWithColor:(UIColor*)color;
+(NSInteger)timeStringToSecond:(NSString*)string;//HH:mm:ss
+(NSString*)timeToChineseCalendar:(double)time;
+(NSString*)timeToString1:(double)time;//yyyy-MM-dd HH:mm
/**
 *  字符串转json
 */
+ (id)stringToJson:(NSString *)jsonString;
/**
 *  json转字符串
 */
+ (NSString*)jsonToString:(id)json;
+ (BOOL)canPlayNew:(NSString*)newsId;
+ (NSUInteger)stringLength:(NSString*)string;
//判断是否第一次打开
+(BOOL)isFirstOpen:(NSString *)key;
+(BOOL)isTodayTime:(double)time;
@end
