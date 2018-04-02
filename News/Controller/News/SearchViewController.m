//
//  SearchViewController.m
//  News
//
//  Created by Innovation on 17/11/19.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "SearchViewController.h"
#import "NewsCell.h"
#import "WhiteView.h"
#import "LabelModel1.h"

#define kSearchHistoryKey @"kSearchHistoryKey"

@interface SearchCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
@end

@implementation SearchCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *whiteView = [[WhiteView alloc]initWithFrame:self.bounds];
        whiteView.autoresizingMask = UIViewAutoresizingFlexibleCenter | UIViewAutoresizingFlexibleSize;
        [self addSubview:whiteView];
        self.label = [[LabelModel1 alloc]initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleCenter | UIViewAutoresizingFlexibleSize;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    return self;
}

@end

@interface SearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>
{
    BOOL _isSearch;
    NSString *_searchKey;
}
@property (nonatomic, strong) NSArray *histroy;
@property (nonatomic, strong) NSArray *hot;
@property (nonatomic, strong) NSMutableArray *result;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView2;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout1;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout2;
@property (weak, nonatomic) IBOutlet UIView *hotView;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupForDismissKeyboard];
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults]objectForKey:kSearchHistoryKey];
    self.histroy = array;
    self.hot = [[NSMutableArray alloc]init];
    self.result = [[NSMutableArray alloc]init];
    [self getHotList];
    [self setupCollectionView];
    [self setupNavigation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshFrame];
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme){
        self.collectionView1.backgroundColor = SplitLineColorLight;
        self.collectionView2.backgroundColor = SplitLineColorLight;
        self.tableView.backgroundColor = LightBackgroundColor;
    }
    else{
        self.collectionView1.backgroundColor = SplitLineColor;
        self.collectionView2.backgroundColor = SplitLineColor;
        self.tableView.backgroundColor = DayBackgroundColor;
    }
}

- (void)refreshFrame
{
    self.collectionView1.height = self.layout1.collectionViewContentSize.height;
    self.collectionView2.height = self.layout2.collectionViewContentSize.height;
    self.hotView.top = self.collectionView1.bottom + 10;
    self.hotView.height = self.collectionView2.bottom;
    self.scrollView.contentSize = CGSizeMake(0, self.hotView.bottom);
    self.tableView.hidden = !_isSearch;
}
- (IBAction)cleanHistory:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kSearchHistoryKey];
    self.histroy = nil;
    [self.collectionView1 reloadData];
    [self refreshFrame];
}

- (void)setupNavigation
{
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = cornerRadiusWidth;
    self.searchView.width = ScreenWidth - 150;
    self.navigationItem.titleView = self.searchView;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmAct) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:rightBarItem];
}

- (void)setupCollectionView
{
    [self.collectionView1 registerClass:[SearchCell class] forCellWithReuseIdentifier:@"SearchCell"];
    [self.collectionView2 registerClass:[SearchCell class] forCellWithReuseIdentifier:@"SearchCell"];
    self.layout1.minimumLineSpacing = 0.5;
    self.layout1.minimumInteritemSpacing = 1;
    self.layout1.itemSize = CGSizeMake((ScreenWidth)/2.0-0.5, 30);
    self.layout2.minimumLineSpacing = 0.5;
    self.layout2.minimumInteritemSpacing = 1;
    self.layout2.itemSize = CGSizeMake((ScreenWidth)/2.0-0.5, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)confirmAct
{
    if (self.searchField.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入关键词"];
        return;
    }
    [MobClick event:@"searchNews"];
    [self.view endEditing:YES];
    _isSearch = YES;
    _searchKey = self.searchField.text;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:kSearchHistoryKey]];
    [array insertObject:self.searchField.text atIndex:0];
    self.histroy = array;
    [[NSUserDefaults standardUserDefaults]setObject:array forKey:kSearchHistoryKey];
    [self.collectionView1 reloadData];
    [self refreshFrame];
    [self searchNews];
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView1) {
        return MIN(20, self.histroy.count);
    }
    return self.hot.count;
}

- (__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
    NSString *string = nil;
    if (collectionView == self.collectionView1) {
        string = [self.histroy objectAtIndex:indexPath.row];
    }
    else{
        string = [self.hot objectAtIndex:indexPath.row];
    }
    cell.label.text = string;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = nil;
    if (collectionView == self.collectionView1) {
        string = [self.histroy objectAtIndex:indexPath.row];
    }
    else{
        string = [self.hot objectAtIndex:indexPath.row];
    }
    _isSearch = YES;
    _searchKey = string;
    self.searchField.text = string;
    [self refreshFrame];
    [self searchNews];
}

- (void)getHotList
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=search" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            self.hot = array;
            [self.collectionView2 reloadData];
            [self refreshFrame];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)searchNews{
    NSDictionary *dict = @{@"search":_searchKey};
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=search&op=addSearch" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self.result removeAllObjects];
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSArray *newList = [dict safeArrayForKey:@"newlist"];
            NSArray *array = [NewsObject mj_objectArrayWithKeyValuesArray:newList];
            [self.result addObjectsFromArray:array];
            [self.tableView reloadData];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView.hidden) {
        self.tipLabel.hidden = YES;
    }
    else{
        self.tipLabel.hidden = self.result.count != 0;
    }
    return self.result.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"NewsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"NewsCell" owner:self options:nil][0];
    }
    [cell.content setVerticalAlignment:VerticalAlignmentTop];
    NewsObject *news = [self.result objectAtIndex:indexPath.row];
    
    cell.news = news;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsObject *news = [self.result objectAtIndex:indexPath.row];
    return [NewsCell cellHeight:news];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsObject *news = [self.result objectAtIndex:indexPath.row];
    news.isSpread = !news.isSpread;
    [self.tableView reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([Tool stringLength:text] > 40) {
        return NO;
    }
    return YES;
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
