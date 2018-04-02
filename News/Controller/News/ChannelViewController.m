//
//  ChannelViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/1.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ChannelViewController.h"
#import "UIBarButtonItem+SXCreate.h"
#import "ChannelCell.h"
#import "LoginView.h"
#import "LoginViewController.h"

@interface ChannelViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _isDissmiss;
    BOOL _hasChange;
}
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView2;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout1;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout2;
@property (weak, nonatomic) IBOutlet UIView *addView;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *myChannel;
@property (strong, nonatomic) NSMutableArray *unselectData;

@property (nonatomic) BOOL isEditModel;

@property (nonatomic, strong) NSDictionary *recommend;

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"频道管理";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.editButton.layer.cornerRadius = self.editButton.height/2.0;
    self.editButton.layer.borderWidth = 0.5;
    self.editButton.layer.masksToBounds = YES;
    self.editButton.layer.borderColor = [UIColor redColor].CGColor;
    
    UIBarButtonItem *rightBarItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightAct) image:[UIImage imageNamed:@"close"] imageEdgeInsets:UIEdgeInsetsZero];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self.collectionView1 registerClass:[ChannelCell class] forCellWithReuseIdentifier:@"ChannelCell"];
    [self.collectionView2 registerClass:[ChannelCell class] forCellWithReuseIdentifier:@"ChannelCell"];
    CGFloat itemspace = 15;
    CGFloat count = 4.0;
    CGFloat itemwidth = (ScreenWidth-32-(count-1)*itemspace)/count;
    self.layout1.itemSize = CGSizeMake(itemwidth, 25);
    self.layout1.minimumLineSpacing = itemspace;
    
    self.layout2.itemSize = self.layout1.itemSize;
    self.layout2.minimumLineSpacing = self.layout1.minimumLineSpacing;
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestrue:)];
    [self.collectionView1 addGestureRecognizer:gesture];
    
    self.data = [NSMutableArray arrayWithArray:self.like];
    [self.data addObjectsFromArray:self.dislike];
    self.unselectData = [NSMutableArray arrayWithArray:self.dislike];
    self.myChannel = [NSMutableArray arrayWithArray:self.like];
    for (NSDictionary *dicct in self.myChannel) {
        if ([dicct safeIntForKey:@"channel_id"] == 0) {
            self.recommend = dicct;
            [self.myChannel removeObject:dicct];
            break;
        }
    }
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme){
        self.collectionView1.backgroundColor = GrayColorLight;
        self.collectionView2.backgroundColor = GrayColorLight;
    }
    else{
        self.collectionView1.backgroundColor = GrayColor;
        self.collectionView2.backgroundColor = GrayColor;
    }
}

- (void)rightAct
{
    if (_hasChange) {
        _isDissmiss = YES;
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self saveChannelList];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)editAct:(UIButton *)sender {
    self.isEditModel = !self.isEditModel;
    if (!self.isEditModel) {
        [self saveChannelList];
    }
    else{
        _hasChange = YES;
        [MobClick event:@"manageChannel"];
    }
}

- (void)saveChannelList
{
    if (!HTTPClientInstance.isLogin) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录再进行操作" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            LoginView *view = [[NSBundle mainBundle]loadNibNamed:@"LoginView" owner:self options:nil][0];
            view.frame = ScreenBounds;
            view.naviVc = self.navigationController;
            [AppDelegateInstance.window addSubview:view];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:act1];
        [alert addAction:act2];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in self.myChannel) {
        [array addObject:[dict safeObjectForKey:@"channel_id"]];
    }
    [array insertObject:@1 atIndex:0];
    NSString *string = [array componentsJoinedByString:@","];
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=channel&op=channeledit" params:@{@"like":string} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.myChannel];
            [array insertObject:self.recommend atIndex:0];
            self.sortFinish(array, self.unselectData);
            if (_isDissmiss) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            _hasChange = NO;
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)setIsEditModel:(BOOL)isEditModel
{
    _isEditModel = isEditModel;
    if (isEditModel) {
        [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    else{
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView1.height = self.layout1.collectionViewContentSize.height;
    self.collectionView2.height = self.layout2.collectionViewContentSize.height;
    self.addView.top = self.collectionView1.bottom + 10;
    self.addView.height = self.collectionView2.bottom;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView1) {
        return self.myChannel.count;
    }
    else{
        return self.unselectData.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    if (collectionView == self.collectionView1) {
        cell.closeImage.hidden = !self.isEditModel;
        NSDictionary *dict = self.myChannel[indexPath.row];
        NSString *string = [dict safeStringForKey:@"channel_content"];
        cell.label.text = string;
    }
    else if (collectionView == self.collectionView2){
        cell.closeImage.hidden = YES;
        NSDictionary *dict = self.unselectData[indexPath.row];
        NSString *string = [dict safeStringForKey:@"channel_content"];
        cell.label.text = string;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isEditModel) {
        return;
    }
    if (collectionView == self.collectionView2) {
        id object = self.unselectData[indexPath.row];
        [self.unselectData removeObject:object];
        [self.collectionView2 deleteItemsAtIndexPaths:@[indexPath]];
        [self.myChannel addObject:object];
        [self.collectionView1 reloadData];
        self.collectionView1.height = self.layout1.collectionViewContentSize.height;
        self.collectionView2.height = self.layout2.collectionViewContentSize.height;
        self.addView.top = self.collectionView1.bottom + 10;
        self.addView.height = self.collectionView2.bottom;
    }
    if (collectionView == self.collectionView1) {
        id object = self.myChannel[indexPath.row];
        [self.myChannel removeObject:object];
        [self.collectionView1 deleteItemsAtIndexPaths:@[indexPath]];
        [self.unselectData addObject:object];
        [self.collectionView2 reloadData];
        self.collectionView1.height = self.layout1.collectionViewContentSize.height;
        self.collectionView2.height = self.layout2.collectionViewContentSize.height;
        self.addView.top = self.collectionView1.bottom + 10;
        self.addView.height = self.collectionView2.bottom;
    }
}

#pragma mark - iOS9 之后的方法
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView1) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //取出移动row数据
    id object = self.myChannel[sourceIndexPath.row];
    //从数据源中移除该数据
    [self.myChannel removeObject:object];
    //将数据插入到数据源中的目标位置
    [self.myChannel insertObject:object atIndex:destinationIndexPath.row];
}

- (void)longPressGestrue:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        { //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self.collectionView1 indexPathForItemAtPoint:[longPress locationInView:self.collectionView1]];
            if (indexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView1 cellForItemAtIndexPath:indexPath];
            [self.view bringSubviewToFront:cell];
            //iOS9方法 移动cell
            [self.collectionView1 beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势改变
            // iOS9方法 移动过程中随时更新cell位置
            if (!self.isEditModel) {
                return;
            }
            [self.collectionView1 updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView1]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        { // 手势结束
            // iOS9方法 移动结束后关闭cell移动
            [self.collectionView1 endInteractiveMovement];
        }
            break;
        default: //手势其他状态
            [self.collectionView1 cancelInteractiveMovement];
            break;
    }
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
