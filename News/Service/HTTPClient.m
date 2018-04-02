//
//  HTTPClient.m
//  Miju
//
//  Created by Roger on 12/9/13.
//  Copyright (c) 2013 Miju. All rights reserved.
//

#import "HTTPClient.h"

static HTTPClient *_instance = nil;
@interface HTTPClient ()
@end

@implementation HTTPClient

+ (instancetype)instance
{
    if (!_instance)
    {
        _instance = [[HTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:base_url]]];
        _instance.responseSerializer.acceptableContentTypes = [_instance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        _instance.responseSerializer.acceptableContentTypes = [_instance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    }
    return _instance;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        [self readLoginData];
    }
    return self;
}

- (NSMutableDictionary*)newDefaultParameters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"ios" forKey:@"client"];
    if(self.token != nil) {
        [parameters setObject:self.token forKey:@"key"];
    }
    else
    {
        [self readLoginData];
        if (self.token!=nil) {
            [parameters setObject:self.token forKey:@"key"];
        }
    }
    return parameters;
}

- (BOOL)isLogin
{
    return self.uid && self.token;
}

- (void)setUid:(NSString *)new_uid token:(NSString*)new_token
{
    if ([new_uid isKindOfClass:[NSString class]])
    {
        self.uid = [NSString stringWithString:new_uid];
    }
    else
    {
        self.uid = [NSString stringWithFormat:@"%lld", new_uid.longLongValue];
    }
    
    self.token = [NSString stringWithString:new_token];
    [self saveLoginData];
}

- (void)readLoginData
{
    NSString* login_uid_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLoginUidToken"];
    if (login_uid_token.length > 0)
    {
        NSArray* array = [login_uid_token componentsSeparatedByString:@"__"];
        if (array.count >= 2)
        {
            [self setUid:[array objectAtIndex:0] token:[array objectAtIndex:1]];
        }
    }
}

- (void)saveLoginData
{
    NSString* login_uid_token = [NSString stringWithFormat:@"%@__%@", self.uid, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:login_uid_token forKey:@"kLoginUidToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearLoginData
{
    self.uid = nil;
    self.token = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kLoginUidToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)postMethod:(NSString *)method params:(NSDictionary *)params block:(GetRequestBlock)block
{
    NSMutableDictionary* dict = [HTTPClientInstance newDefaultParameters];
    [dict addEntriesFromDictionary:params];
    NSLog(@"requestMethod(begin):%@",method);
    [HTTPClientInstance POST:[NSString stringWithFormat:@"mobile/index.php?%@",method] parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
    }  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"requestMethod(end):%@",method);
        NSDictionary *dic = responseObject;
        block(dic,[dic safeStringForKey:@"msg"],[dic safeIntForKey:@"code"],nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"requestMethod(end):%@",method);
        block(nil,nil,400,error);
    }];
}

- (void)uploadImage:(UIImage *)image block:(GetRequestBlock)block
{
    [HTTPClientInstance POST:@"mobile/index.php?act=upload&op=index" parameters:[HTTPClientInstance newDefaultParameters] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //上传
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 对应网站上[upload.php中]处理文件的[字段"file"]
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         */
        NSString *fileName = [self getUploadImageName];
        NSData *fileData = UIImageJPEGRepresentation(image, 1);
        NSInputStream *inputStream = [NSInputStream inputStreamWithData:fileData];
        [formData appendPartWithInputStream:inputStream name:@"data" fileName:fileName length:fileData.length mimeType:@"jpg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        block(dic,[dic safeStringForKey:@"msg"],[dic safeIntForKey:@"code"],nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil,nil,400,error);
    }];
}
- (NSString*)getUploadImageName{
    // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
    // 要解决此问题，
    // 可以在上传时使用当前的系统事件作为文件名
    NSDate *date = [NSDate date];
    long long dateTime = date.timeIntervalSince1970*1000;
    int ramValue = arc4random()%1000;
    NSString *fileName = [NSString stringWithFormat:@"%lld%d.jpg", dateTime, ramValue];
    return fileName;
    
}

@end
