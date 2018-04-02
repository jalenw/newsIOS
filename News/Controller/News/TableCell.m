//
//  TableCell.m
//  News
//
//  Created by ye jiawei on 2017/11/1.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "TableCell.h"
#import "MJRefresh.h"
#import "NewsObject.h"
#import "Ad.h"
#import "AdCell.h"
#import "WebViewController.h"
#import "WhiteView.h"
#import "LabelModel1.h"
#import "EndCell.h"

@interface TableCell()<UITableViewDelegate, UITableViewDataSource>


@end

@implementation TableCell

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.tableView = [[UITableView alloc]initWithFrame:self.bounds];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
        [self addSubview:self.tableView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeFontChange) name:kNotificationModelFontChange object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
        [self themeColorChange];
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedRowHeight = 0;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    return keys.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (section == keys.count) {
        return self.showEnd ? 1 : 0;
    }
    NSString *key = [keys objectAtIndex:section];
    NSDictionary *dict = [self.data objectForKey:@"channel_data"];
    NSArray *arr = [dict objectForKey:key];
    return arr.count;
}

- (void)setData:(NSDictionary *)data
{
    _data = data;
    [self.tableView reloadData];
}

- (void)themeFontChange
{
    [self.tableView reloadData];
}
- (void)themeColorChange{
    if ([ThemeManager instance].isDarkTheme) {
        self.tableView.backgroundColor = LightBackgroundColor;
    }
    else{
        self.tableView.backgroundColor = DayBackgroundColor;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (indexPath.section == keys.count) {
        EndCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EndCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"EndCell" owner:self options:nil][0];
        }
        return cell;
    }
    NSString *identify = @"NewsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"NewsCell" owner:self options:nil][0];
    }
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSDictionary *dict = [self.data objectForKey:@"channel_data"];
    NSArray *arr = [dict objectForKey:key];
    [cell.content setVerticalAlignment:VerticalAlignmentTop];
    NewsObject *news = [arr objectAtIndex:indexPath.row];
    cell.news = news;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (indexPath.section == keys.count) {
        return self.showEnd ? 44 : 0;
    }
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSDictionary *dict = [self.data objectForKey:@"channel_data"];
    NSArray *arr = [dict objectForKey:key];
    NewsObject *news = [arr objectAtIndex:indexPath.row];
    return [NewsCell cellHeight:news];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (indexPath.section == keys.count) {
        return;
    }
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSDictionary *dict = [self.data objectForKey:@"channel_data"];
    NSArray *arr = [dict objectForKey:key];
    NewsObject *news = [arr objectAtIndex:indexPath.row];
    news.isSpread = !news.isSpread;
    if (news.isSpread) {
        [MobClick event:@"newsClick" label:[NSString stringWithFormat:@"%@",news.news_id]];
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (section == keys.count) {
        return 0;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (section == keys.count) {
        return nil;
    }
    WhiteView *whiteView = [[WhiteView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    NSString *key = [keys objectAtIndex:section];
    LabelModel1 *label = [[LabelModel1 alloc]initWithFrame:whiteView.bounds];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = key;
    [whiteView addSubview:label];
    if ([key isEqualToString:@"top"]) {
        NSDictionary *dict = [self.data objectForKey:@"channel_data"];
        NSArray *arr = dict[key];
        NewsObject *news = [arr objectAtIndex:0];
        label.text = news.news_date;
    }
    return whiteView;
}

- (void)headerRefresh
{
    [self reloadData:0 block:^{
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)footerRefresh
{
    NSArray *keys = [self.data objectForKey:@"keys"];
    if (keys > 0) {
        NSString *key = [keys lastObject];
        NSDictionary *dict = [self.data objectForKey:@"channel_data"];
        NSArray *arr = [dict objectForKey:key];
        if (arr.count>0) {
            NewsObject *news = [arr lastObject];
            [self reloadData:[news.news_showtime doubleValue] block:^{
                [self.tableView.mj_footer endRefreshing];
            }];
        }
    }
    else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)reloadData:(NSInteger)time block:(void(^)(void))block
{
    [self.tableCellDelegate tableCell:self loadNewsListData:time block:block];
}

@end
