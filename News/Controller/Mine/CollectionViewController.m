//
//  CollectionViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "CollectionViewController.h"
#import "MyCommonCell.h"
#import "NewsDetailViewController.h"
#import "NewsObject.h"

@interface CollectionViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"收藏";
    self.data = [[NSMutableArray alloc]init];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getList
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=newsuser&op=colloctNewsList" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self.data addObjectsFromArray:[data safeArrayForKey:@"datas"]];
            [self.tableView reloadData];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"MyCommonCell";
    MyCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:identify owner:self options:nil][0];
        [cell.button setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
    NSDictionary *object = [self.data objectAtIndex:indexPath.row];
    cell.timeLabel.text = [Tool timeToString1:[[object safeNumberForKey:@"new_createtime"] doubleValue]];
    cell.content.text = [object safeStringForKey:@"new_title"];
    __weak CollectionViewController *weakSelf = self;
    cell.buttonAct = ^(UIButton *sender) {
        [weakSelf deleteNews:object];
    };
    return cell;
}

- (void)deleteNews:(NSDictionary*)object
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=newsuser&op=colloctNews" params:@{@"new_id":[object safeNumberForKey:@"new_id"]} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self.data removeObject:object];
            [self.tableView reloadData];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [self.data objectAtIndex:indexPath.row];
    NewsDetailViewController *vc = [[NewsDetailViewController alloc]init];
    NewsObject *news = [NewsObject mj_objectWithKeyValues:object];
    news.collected = YES;
    vc.news = news;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
