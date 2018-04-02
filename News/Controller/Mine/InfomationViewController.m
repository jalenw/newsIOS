//
//  InfomationViewController.m
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "InfomationViewController.h"
#import "CustomPickerView.h"
#import "MyCommonCell.h"
#import "NewsObject.h"
#import "PostViewController.h"

@interface InfomationViewController ()<CustomPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL _searchModel;
    BOOL _isSearch;
    int _page;
}
@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *channelField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (strong, nonatomic) NSMutableDictionary *searchParam;

@end

@implementation InfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchParam = [[NSMutableDictionary alloc]init];
    if (self.type == infomationCheck) {
        self.title = @"审核资讯";
    } else {
        self.title = @"管理资讯";
    }
    [self setupForDismissKeyboard];
    self.data = [[NSMutableArray alloc]init];
    self.searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self.searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchBtn addTarget:self action:@selector(searchAct) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBtn];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerViewRefresh)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerViewRefresh)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _page = 0;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchAct
{
    if (!_searchModel) {
        self.searchView.layer.masksToBounds = YES;
        self.searchView.layer.cornerRadius = cornerRadiusWidth;
        self.searchView.width = ScreenWidth - 150;
        self.navigationItem.titleView = self.searchView;
        [self.searchBtn setImage:nil forState:UIControlStateNormal];
        [self.searchBtn setTitle:@"确定" forState:UIControlStateNormal];
        _searchModel = YES;
        return;
    }
    _isSearch = YES;
    [self.searchParam setValue:self.searchField.text forKey:@"search"];
    [self.tableView.mj_header beginRefreshing];
}

- (void)headerViewRefresh
{
    _page = 0;
    [self.tableView.mj_footer setHidden:NO];
    [self getData];
}

- (void)footerViewRefresh
{
    _page++;
    [self getData];
}

- (IBAction)selectChannel:(UIButton *)sender {
    CustomPickerView *picker = [CustomPickerView customPickerWithChannel];
    picker.delegate = self;
}
- (IBAction)selectDate:(UIButton *)sender {
    CustomPickerView *view = [CustomPickerView datePickerView:UIDatePickerModeDate];
    view.delegate = self;
    [view showPicker];
}

- (void)customPickerViewDidSelected:(CustomPickerView *)view customDict:(NSDictionary *)dict
{
    _isSearch = YES;
    NSDictionary *channel = [dict safeDictionaryForKey:@"0"];
    self.channelField.text = [channel safeStringForKey:@"channel_content"];
    int channel_id = [channel safeIntForKey:@"channel_id"];
    [self.searchParam setObject:@(channel_id) forKey:@"channel_id"];
    [self.tableView.mj_header beginRefreshing];
}

- (void)customPickerViewDidSelected:(CustomPickerView *)view date:(NSDate *)date dateString:(NSString *)dateString
{
    _isSearch = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    NSString *string = [dateFormatter stringFromDate:date];
    self.dateField.text = string;
    NSDate *nowDate = [dateFormatter dateFromString:string];
    double old = [date timeIntervalSince1970];
    double start = [nowDate timeIntervalSince1970];
    [self.searchParam setObject:@(start) forKey:@"time"];
    [self.tableView.mj_header beginRefreshing];
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
        [cell.button setTitle:@"删除" forState:UIControlStateNormal];
    }
    cell.baoView.hidden = YES;
    NSDictionary *object = object = [self.data objectAtIndex:indexPath.row];
    NSNumber *time = [object safeNumberForKey:@"new_createtime"];
    cell.timeLabel.text = [Tool timeToString1:[time doubleValue]];
    cell.content.text = [object safeStringForKey:@"new_title"];
    if (self.type == infomationCheck) {
        time = [object safeNumberForKey:@"new_publictime"];
    }
    else{
        [cell.timeLabel sizeToFit];
        cell.baoView.hidden = NO;
        cell.name.text = [object safeStringForKey:@"new_uname"];
        [cell.name sizeToFit];
        cell.baoView.left = cell.timeLabel.right + 5;
        cell.baoView.width = cell.name.right;
        if (cell.baoView.right > cell.button.left - 10) {
            cell.baoView.width = cell.button.left-cell.baoView.left - 10;
            cell.name.width = cell.baoView.width - cell.name.left;
        }
        if ([[NSString stringWithFormat:@"%@",[object safeStringForKey:@"new_type"]] isEqualToString:@"0"]) {
            cell.showTop.hidden = NO;
        }
        else{
            cell.showTop.hidden = YES;
        }
    }
    __weak InfomationViewController *weakSelf = self;
    cell.buttonAct = ^(UIButton *sender) {
        [weakSelf showDeleteView:object];
    };
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = object = [self.data objectAtIndex:indexPath.row];
    PostViewController *vc = [[PostViewController alloc]init];
    vc.news = object;
    if (self.type == infomationCheck) {
        vc.isCheck = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getData{
    NSString *method = self.type==infomationCheck ? @"act=news&op=adminIdentify" : @"act=news&op=identifyNew";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_isSearch) {
        method = self.type==infomationCheck ? @"act=newsuser&op=searchNews1" : @"act=newsuser&op=searchNews";
        [dict addEntriesFromDictionary:self.searchParam];
    }
    [SVProgressHUD show];
    [dict setObject:@(_page) forKey:@"page"];
    [HTTPClientInstance postMethod:method params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            if (_page == 0) {
                [self.data removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            else{
                [self.tableView.mj_footer endRefreshing];
            }
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (array.count < 15) {
                [self.tableView.mj_footer setHidden:YES];
            }
            [self loadDataSuccess:array];
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

- (void)loadDataSuccess:(NSArray*)array;
{
    NSMutableArray *mularr = [NSMutableArray arrayWithArray:array];
    [mularr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1 safeLongLongForKey:@"new_createtime"]<[obj2 safeLongLongForKey:@"new_createtime"];
    }];
    [self.data addObjectsFromArray:mularr];
    [self.tableView reloadData];
}

- (void)deleteNews:(NSDictionary*)object
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=deleteNews" params:@{@"new_id":[object safeNumberForKey:@"new_id"]} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
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

- (void)showDeleteView:(NSDictionary*)object
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否确认删除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteNews:object];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:act1];
    [alert addAction:act2];
    [self presentViewController:alert animated:YES completion:nil];
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
