//
//  NewsTabView.h
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTabView : UIView

@property (nonatomic, strong) void (^addMethod)(void);
@property (nonatomic, strong) void (^selectIndexPath)(NSIndexPath* indexPath);
@property (nonatomic, strong) NSArray *data;

@property (nonatomic) int selectIndex;

- (void)reloadData;

@end
