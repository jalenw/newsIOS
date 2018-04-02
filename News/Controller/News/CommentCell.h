//
//  CommentCell.h
//  News
//
//  Created by ye jiawei on 2017/11/7.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@protocol CommentCellDelegate <NSObject>

- (void)reply:(Comment*)comment;

@end

@interface CommentCell : UITableViewCell

@property (nonatomic, strong)Comment *comment;
@property (nonatomic, weak) id<CommentCellDelegate>delegate;


@end
