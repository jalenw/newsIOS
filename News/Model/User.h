//
//  User.h
//  News
//
//  Created by ye jiawei on 2017/11/15.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSNumber *member_id;
//登录账号
@property (nonatomic, strong) NSString *member_name;
//昵称
@property (nonatomic, strong) NSString *member_nickname;
//真实姓名
@property (nonatomic, strong) NSString *member_truename;
@property (nonatomic, strong) NSString *member_mobile;
@property (nonatomic, strong) NSString *member_email;
@property (nonatomic, strong) NSNumber *member_identity;
@property (nonatomic, strong) NSNumber *member_edit;
@property (nonatomic) int member_type;//0普通用户，1作者2管理员
@property (nonatomic, strong) NSString *member_avatar;

@end
