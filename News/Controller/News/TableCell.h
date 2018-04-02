//
//  TableCell.h
//  News
//
//  Created by ye jiawei on 2017/11/1.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCell.h"

@class TableCell;
@protocol TableCellDelegate <NSObject>
- (void)tableCell:(TableCell*)cell loadNewsListData:(NSInteger)time block:(void(^)(void))block;
@end


@interface TableCell : UICollectionViewCell

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *channel;
@property (nonatomic) BOOL showEnd;
@property (nonatomic, weak) id<TableCellDelegate>tableCellDelegate;

@end
