//
//  Tool.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "Tool.h"
#import "ChinestCalendar.h"
#import "NewsObject.h"

@implementation Tool

+(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize string:(NSString*)string{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attrs = @{NSFontAttributeName : font,
                            NSParagraphStyleAttributeName : paragraphStyle.copy};
    
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

+(UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(NSInteger)timeStringToSecond:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@":"];
    NSInteger hour = [array[0] integerValue];
    NSInteger min = [array[1] integerValue];
    NSInteger second = [array[2] integerValue];
    return hour*3600 + min*60 + second;
}

+(NSString *)timeToChineseCalendar:(double)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    NSInteger weekday = localeComp.weekday;
    NSString *weekDayStr = @"";
    switch(weekday) {
        case 1:
            weekDayStr = @"星期日";
            break;
        case 2:
            weekDayStr = @"星期一";
            break;
        case 3:
            weekDayStr = @"星期二";
            break;
        case 4:
            weekDayStr = @"星期三";
            break;
        case 5:
            weekDayStr = @"星期四";
            break;
        case 6:
            weekDayStr = @"星期五";
            break;
        case 7:
            weekDayStr = @"星期六";
            break;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *string = [dateFormatter stringFromDate:date];
    NSString *string2 = [ChinestCalendar getChineseCalendarWithDate:date];
    return [NSString stringWithFormat:@"%@    %@    %@",string,weekDayStr,string2];
}

+(NSString *)timeToString1:(double)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}

+ (id)stringToJson:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return object;
}

+ (NSString*)jsonToString:(id)json
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (BOOL)canPlayNew:(NSString *)newsId
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    NSString *playList = [[NSUserDefaults standardUserDefaults]objectForKey:kNewsPlayList];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[playList componentsSeparatedByString:@","]];
    if ([array containsObject:newsId]) {
        return NO;
    }
    [array addObject:newsId];
    playList = [array componentsJoinedByString:@","];
    [[NSUserDefaults standardUserDefaults]setObject:playList forKey:kNewsPlayList];
    return YES;
}

+ (NSUInteger)stringLength:(NSString *)string
{
    NSUInteger characterLength = 0;
    char *p = (char *)[string cStringUsingEncoding:NSUnicodeStringEncoding];
    for (NSInteger i = 0, l = [string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i < l; i++) {
        if (*p) {
            characterLength++;
        }
        p++;
    }
    return characterLength;
}

+(BOOL)isFirstOpen:(NSString *)key
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"everLaunched%@",key]]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"everLaunched%@",key]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+(BOOL)isTodayTime:(double)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    NSString *string = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *today = [dateFormatter dateFromString:string];
    double todayBegin = [today timeIntervalSince1970];
    return time > todayBegin;
}

@end
