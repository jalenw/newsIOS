//
//  JsonHelper.h
//  Linke
//
//  Created by intexh on 16/12/15.
//  Copyright © 2016年 intexh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonHelper : NSObject

+(NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;
+(NSString *)jsonStringWithArray:(NSArray *)array;
+(NSString *)jsonStringWithString:(NSString *) string;
+(NSString *)jsonStringWithObject:(id) object;

@end
