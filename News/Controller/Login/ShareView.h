//
//  ShareView.h
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareContent;
@property (nonatomic, strong) id images;
@property (nonatomic, strong) NSString *shareType;//newsShare,adShare,friendShare

@end
