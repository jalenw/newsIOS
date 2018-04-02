//
//  AddAdertisementViewController.m
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "AddAdertisementViewController.h"
#import "UIScrollView+LZHSimpleFunction.h"

@interface AddAdertisementViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *inputCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *company;
@property (weak, nonatomic) IBOutlet UITextField *budget;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@end

@implementation AddAdertisementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"广告投放";
    [self setupForDismissKeyboard];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView lzh_addNotificationForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView lzh_removeNotifiacitonForKeyboard];
}

- (IBAction)submit:(UIButton *)sender {
    if (self.name.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入联系人"];
        return;
    }
    
    if ([Tool stringLength:self.name.text] > 20) {
        [AlertHelper showAlertWithTitle:@"联系人长度超出限制"];
        return;
    }
    if (self.phone.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入手机号"];
        return;
    }
    if (self.phone.text.length != 11) {
        [AlertHelper showAlertWithTitle:@"请输入正确手机号"];
        return;
    }
    if (self.company.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入公司名"];
        return;
    }
    if ([Tool stringLength:self.company.text] > 30) {
        [AlertHelper showAlertWithTitle:@"公司名长度超出限制"];
        return;
    }
    if (self.budget.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入广告预算"];
        return;
    }
    if ([Tool stringLength:self.name.text] > 60) {
        [AlertHelper showAlertWithTitle:@"广告预算长度超出限制"];
        return;
    }
    NSDictionary *dict = @{@"contact_name":self.name.text,
                           @"contact_phone":self.phone.text,
                           @"contact_company":self.company.text,
                           @"contact_count":self.budget.text};
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=contactNew" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [AlertHelper showAlertWithTitle:@"提交成功"];
            [MobClick event:@"advertisement"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)getData
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=base" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [self.button1 setTitle:[dict safeStringForKey:@"gdphone"] forState:UIControlStateNormal];
            [self.button2 setTitle:[dict safeStringForKey:@"gdtel"] forState:UIControlStateNormal];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}
- (IBAction)call:(UIButton *)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",sender.titleLabel.text]]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return _phoneCell;
    }
    return _inputCell;
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
