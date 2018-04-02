//
//  MessageViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/22.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "MessageViewController.h"
#import "MyCommonCell.h"

@interface MessageViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    int _page;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息";
    self.data = [[NSMutableArray alloc]init];
    [self getList];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)headerRefresh
{
    _page = 0;
    self.tableView.mj_footer.hidden = NO;
    [self getList];
}

- (void)footerRefresh
{
    _page++;
    [self getList];
}

- (void)getList
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=message" params:@{@"page":@(_page)} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (_page == 0) {
                [self.data removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            else{
                [self.tableView.mj_footer endRefreshing];
            }
            if (array.count < 15) {
                self.tableView.mj_footer.hidden = YES;
            }
            [self.data addObjectsFromArray:array];
            [self.tableView reloadData];
        }
        else{
            if (_page == 0) {
                [self.tableView.mj_header endRefreshing];
            }
            else{
                [self.tableView.mj_footer endRefreshing];
            }
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
        cell.button.hidden = YES;
    }
    NSDictionary *object = [self.data objectAtIndex:indexPath.row];
    cell.timeLabel.text = [Tool timeToString1:[[object safeNumberForKey:@"message_time"] doubleValue]];
    cell.content.text = [object safeStringForKey:@"message_content"];
    return cell;
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
