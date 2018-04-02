//
//  MyViewController.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "MyViewController.h"
#import "LoginView.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "EditInfoViewController.h"
#import "FeedBackViewController.h"
#import "PostViewController.h"
#import "InfomationViewController.h"
#import "BecomeEditorViewController.h"
#import "AddAdertisementViewController.h"
#import "CollectionViewController.h"
#import "LikeViewController.h"
#import "MyCommentViewController.h"
#import "AboutViewController.h"
#import "MessageViewController.h"
#import "CoverViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareView.h"
#import "User.h"

@interface MyViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableViewCell *headCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *bottomCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *informationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *functionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *m_informationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *m_functionCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
//function
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UISwitch *aSwitch;
@property (weak, nonatomic) IBOutlet UIButton *dayModel;
@property (weak, nonatomic) IBOutlet UIButton *lightModel;
@property (weak, nonatomic) IBOutlet UIButton *autoModel;

@property (weak, nonatomic) IBOutlet UIView *redPoint;
@property (weak, nonatomic) IBOutlet UIView *redPoint1;

@property (strong, nonatomic) NSArray *data;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.aSwitch.transform = CGAffineTransformMakeScale(35.0/self.aSwitch.width, 20.0/self.aSwitch.height);
    self.segment.selectedSegmentIndex = [ThemeManager instance].textFont+1;
    self.avatarView.layer.cornerRadius = self.avatarView.width/2.0;
    self.segment.layer.borderWidth = 0.5;
    self.redPoint.layer.cornerRadius = self.redPoint.width/2.0;
    self.redPoint1.layer.cornerRadius = self.redPoint1.width/2.0;
    
    if ([ThemeManager instance].isAutoDarkModel) {
        self.autoModel.selected = YES;
    }
    else if ([ThemeManager instance].isDarkTheme) {
        self.lightModel.selected = YES;
    }
    else{
        self.dayModel.selected = YES;
    }
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    }

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self getCommentCount];
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme) {
        [self.segment setTitleTextAttributes:@{NSForegroundColorAttributeName: TextColor1Light} forState:UIControlStateNormal];
        [self.segment setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeColorLight} forState:UIControlStateSelected];
        [self.segment setBackgroundImage:[Tool createImageWithColor:WhiteColorLight] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [self.segment setBackgroundImage:[Tool createImageWithColor:WhiteColorLight] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.segment.layer.borderColor = GrayColorLight.CGColor;
        self.segment.tintColor = GrayColorLight;
    }
    else{
        [self.segment setTitleTextAttributes:@{NSForegroundColorAttributeName: TextColor1} forState:UIControlStateNormal];
        [self.segment setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeColor} forState:UIControlStateSelected];
        [self.segment setBackgroundImage:[Tool createImageWithColor:WhiteColor] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [self.segment setBackgroundImage:[Tool createImageWithColor:WhiteColor] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.segment.layer.borderColor = GrayColor.CGColor;
        self.segment.tintColor = GrayColor;
    }
}

- (void)setupHeaderCell
{
    if ([HTTPClientInstance isLogin]) {
        self.loginButton.hidden = YES;
        self.editButton.hidden = NO;
        self.nameLabel.text = AppDelegateInstance.defaultUser.member_nickname;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:AppDelegateInstance.defaultUser.member_avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }
    else{
        self.editButton.hidden = YES;
        self.loginButton.hidden = NO;
        self.nameLabel.text = @"点击登录";
        self.avatarView.image = [UIImage imageNamed:@"default_avatar"];
    }
    NSArray *user = @[self.headCell,self.functionCell,self.bottomCell];
    NSArray *author = @[self.headCell,self.m_informationCell,self.m_functionCell,self.bottomCell];
    NSArray *manager = @[self.headCell,self.informationCell,self.functionCell,self.bottomCell];
    if (AppDelegateInstance.defaultUser.member_type == 2) {
        self.data = manager;
    }
    else if (AppDelegateInstance.defaultUser.member_type == 1){
        self.data = author;
    }
    else{
        self.data = user;
    }
    self.aSwitch.on = ![ThemeManager instance].isCloseAPNs;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setupHeaderCell];
    [self getCommentCount];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)changeTextFont:(UISegmentedControl *)sender {
    [ThemeManager instance].textFont = (int)sender.selectedSegmentIndex-1;
}

- (IBAction)changeDarkModel:(UIButton*)sender {
    self.dayModel.selected = NO;
    self.lightModel.selected = NO;
    self.autoModel.selected = NO;
    sender.selected = YES;
    [ThemeManager instance].isAutoDarkModel = NO;
    [ThemeManager instance].isDarkTheme = self.lightModel.selected;
}
- (IBAction)autoDarkModel:(UIButton *)sender {
    self.dayModel.selected = NO;
    self.lightModel.selected = NO;
    sender.selected = YES;
    [ThemeManager instance].isAutoDarkModel = YES;
}

- (IBAction)switchchange:(UISwitch*)sender {
    [ThemeManager instance].isCloseAPNs = !sender.on;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.data objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.data objectAtIndex:indexPath.row];
    return cell.height;
}

//action
- (IBAction)login:(UIButton *)sender {
    LoginView *view = [[NSBundle mainBundle]loadNibNamed:@"LoginView" owner:self options:nil][0];
    view.frame = ScreenBounds;
    [AppDelegateInstance.window addSubview:view];
    __weak MyViewController* weakSelf = self;
    view.loginTpye = ^(NSInteger type) {
        switch (type) {
            case 0:
                NSLog(@"login by wechat");
                [self loginWithShareType:SSDKPlatformTypeWechat];
                break;
            case 1:
                NSLog(@"login by qq");
                [self loginWithShareType:SSDKPlatformSubTypeQZone];
                break;
            case 2:
            {
                NSLog(@"login by phone");
                LoginViewController *vc = [[LoginViewController alloc]init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    };
}

- (IBAction)gotoSetting:(UIButton *)sender {
    SettingViewController *vc = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoEditInfo:(UIButton *)sender {
    EditInfoViewController *vc = [[EditInfoViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoFeedBack:(UIButton *)sender {
    FeedBackViewController *vc = [[FeedBackViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addNews:(UIButton *)sender {
    PostViewController *vc = [[PostViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)manageNews:(UIButton *)sender {
    InfomationViewController *vc = [[InfomationViewController alloc]init];
    vc.type = infomationManager;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)checkNews:(UIButton *)sender {
    InfomationViewController *vc = [[InfomationViewController alloc]init];
    vc.type = infomationCheck;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)inviteFriend:(UIButton *)sender {
    ShareView *view = [[NSBundle mainBundle]loadNibNamed:@"ShareView" owner:self options:nil][0];
    view.shareType = @"friendShare";
    view.frame = ScreenBounds;
    [AppDelegateInstance.window addSubview:view];
}

- (IBAction)becomeEditor:(UIButton *)sender {
    BecomeEditorViewController *vc = [[BecomeEditorViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)infomationMessage:(UIButton *)sender {
    MessageViewController *vc = [[MessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)newsFirstPage:(UIButton *)sender {
    CoverViewController *vc = [[CoverViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)bussinessCooperation:(UIButton *)sender {
    [MobClick event:@"bussiness"];
    AboutViewController *vc = [[AboutViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addAdvertisement:(UIButton *)sender {
    AddAdertisementViewController *vc = [[AddAdertisementViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoCollection:(UIButton *)sender {
    CollectionViewController *vc = [[CollectionViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)gotoLike:(UIButton *)sender {
    LikeViewController *vc = [[LikeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoComment:(UIButton *)sender {
    MyCommentViewController *vc = [[MyCommentViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginWithShareType:(SSDKPlatformType)shareType{
    [ShareSDK cancelAuthorize:shareType];
    [ShareSDK getUserInfo:shareType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            [self loginWithUserInfo:user];
        }else if (state == SSDKResponseStateFail || state == SSDKResponseStateCancel){
            
            if (shareType == SSDKPlatformSubTypeQZone) {
                //                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"QQ登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                //                [alertView show];
                [AlertHelper showAlertWithTitle:@"QQ登陆失败"];
            }else if (shareType == SSDKPlatformTypeWechat) {
                [AlertHelper showAlertWithTitle:@"微信登录失败"];
                
            }else if (shareType == SSDKPlatformTypeSinaWeibo){
                [AlertHelper showAlertWithTitle:@"微博登录失败"];
            }
        }
    }];
}

- (void)loginWithUserInfo:(SSDKUser*)userInfo{
    NSString *method = nil;
    NSString *name = userInfo.nickname;
    SSDKCredential *credential = userInfo.credential;
    NSString* openId = [credential uid];
    NSString *icon = userInfo.icon;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:icon forKey:@"headimgurl"];
    [params setValue:name forKey:@"nickname"];
    [params setValue:openId forKey:@"openid"];
    if (userInfo.platformType == SSDKPlatformSubTypeQZone) {
        method = @"act=connect&op=loginByQq";
    }
    else if (userInfo.platformType == SSDKPlatformTypeWechat){
        method = @"act=connect&op=loginByWeixin";
        NSDictionary *rawData = [credential rawData];
        NSString *unionid = [rawData safeStringForKey:@"unionid"];
        [params setValue:unionid forKey:@"unionid"];
    }
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:method params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [HTTPClientInstance setUid:[dict safeStringForKey:@"member_id"] token:[dict safeStringForKey:@"key"]];
            User *user = [User mj_objectWithKeyValues:dict];
            AppDelegateInstance.defaultUser = user;
            [self setupHeaderCell];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)getCommentCount
{
    if (!HTTPClientInstance.isLogin) {
        NSString *string = @"  评论";
        [self.commentBtn setTitle:string forState:UIControlStateNormal];
    }
    [HTTPClientInstance postMethod:@"act=newsuser&op=xiaoxi" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            int commentnum = [dict safeIntForKey:@"commentnum"];
            int systemmessage = [dict safeIntForKey:@"systemmessage"];
            NSString *string = @"  评论";
            if (commentnum == 0) {
                [self.commentBtn setTitle:string forState:UIControlStateNormal];
            }
            else{
                [self.commentBtn setTitle:[NSString stringWithFormat:@"%@ %d",string,commentnum] forState:UIControlStateNormal];
            }
            self.redPoint.hidden = systemmessage == 0;
            self.redPoint1.hidden = systemmessage == 0;
        }
        else{
        }
    }];
}



@end
