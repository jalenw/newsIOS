//
//  HTTPClient.h
//  Miju
//
//  Created by Roger on 12/9/13.
//  Copyright (c) 2013 Miju. All rights reserved.
//

#import "AFNetworking.h"
#define HTTPClientInstance [HTTPClient instance]
typedef void (^GetRequestBlock)(NSDictionary *data,NSString *error,int code,NSError *requestFailed);
@interface HTTPClient : AFHTTPSessionManager
@property NSString* uid;
@property NSString* token;
+ (instancetype)instance;
- (NSMutableDictionary*)newDefaultParameters;
- (void)setUid:(NSString *)new_uid token:(NSString*)new_token;
- (BOOL)isLogin;
- (void)saveLoginData;
- (void)clearLoginData;


- (void)postMethod:(NSString*)method params:(NSDictionary*)params block:(GetRequestBlock)block;
- (void)uploadImage:(UIImage*)image block:(GetRequestBlock)block;

@end
