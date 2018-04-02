//
//  LikeViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "LikeViewController.h"
#import "MyCommonCell.h"
#import "NewsObject.h"
#import "NewsDetailViewController.h"

@interface LikeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation LikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"赞过";
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
    [HTTPClientInstance postMethod:@"act=newsuser&op=payNewsList" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
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
        cell.button.hidden = YES;
    }
    NSDictionary *object = [self.data objectAtIndex:indexPath.row];
    cell.timeLabel.text = [Tool timeToString1:[[object safeNumberForKey:@"new_createtime"] doubleValue]];
    cell.content.text = [object safeStringForKey:@"new_title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [self.data objectAtIndex:indexPath.row];
    NewsDetailViewController *vc = [[NewsDetailViewController alloc]init];
    NewsObject *news = [NewsObject mj_objectWithKeyValues:object];
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
