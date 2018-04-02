//
//  BecomeEditorViewController.m
//  News
//
//  Created by Innovation on 17/11/20.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BecomeEditorViewController.h"
#import "UIBarButtonItem+SXCreate.h"
#import "ProtocolViewController.h"

@interface BecomeEditorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *idcard;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation BecomeEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"申请成为作者";
    [self setupForDismissKeyboard];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:@"申请" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    self.navigationItem.rightBarButtonItem = barItem;
    [self getText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)agreeAct:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)submit:(UIButton *)sender {
    if (self.name.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请填写身份证姓名"];
        return;
    }
    if (self.phone.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请填写手机号码"];
        return;
    }
    if (self.name.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请填写身份证号"];
        return;
    }
    if (!self.agreeBtn.selected) {
        [AlertHelper showAlertWithTitle:@"请阅读新闻平台作者协议"];
        return;
    }
    NSDictionary *dict = @{@"truename":self.name.text,@"mobile":self.phone.text,@"idcard":self.idcard.text};
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=identifyUser" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            if (self.realname) {
                self.realname(self.name.text,self.phone.text);
            }
            [AppDelegateInstance getUserInfo];
            [AlertHelper showAlertWithTitle:@"认证成功"];
            [MobClick event:@"author"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}
- (IBAction)protocolAct:(UIButton *)sender {
    ProtocolViewController *vc = [[ProtocolViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getText
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=base" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            self.tipLabel.text = [dict safeStringForKey:@"yanzheng"];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}
- (IBAction)phoneEnd:(UITextField *)sender {
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=connect&op=checkMobile" params:@{@"phone":self.phone.text} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            if (dict.count>0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"该手机号已经注册，是否放弃该手机号所注册的账号" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:act1];
                [alert addAction:act2];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else{
        }
    }];
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
