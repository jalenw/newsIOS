//
//  BandViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/28.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "BandViewController.h"

@interface BandViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;


//timer
@property (weak, nonatomic) IBOutlet UIButton *codeButton;
@property (assign, nonatomic) int waitingTime;
@property (strong, nonatomic) NSTimer *resendButtonTimer;

@end

@implementation BandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_isBandMail) {
        self.title = @"绑定邮箱";
        self.phone.placeholder = @"邮箱";
        self.phone.keyboardType = UIKeyboardTypeDefault;
    }
    else
    {
        self.title = @"绑定手机";
    }
    [self setupForDismissKeyboard];
    self.contentView.layer.borderWidth = 0.5;
    self.line.height = 0.5;
    self.line.top = 47.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme) {
        self.contentView.layer.borderColor = SplitLineColorLight.CGColor;
    }
    else{
        self.contentView.layer.borderColor = SplitLineColor.CGColor;
    }
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.loginButton.backgroundColor = text.length == 0 ? RGB(163, 163, 163) : ThemeColor;
    self.loginButton.enabled = text.length == 0 ? NO : YES;
    return YES;
}

- (IBAction)sendCode:(UIButton *)sender {
    if (self.phone.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入手机号"];
        return;
    }
    [self checkBand];
}

- (void)startWaitingTime
{
    self.waitingTime = 60;
    self.codeButton.enabled = NO;
    //[self.codeButton setTitleColor:PlaceHolderColor forState:UIControlStateNormal];
    self.codeButton.titleLabel.text =  [NSString stringWithFormat:@"%d秒后重发",self.waitingTime];
    [self.codeButton setTitle:[NSString stringWithFormat:@"%d秒后重发",self.waitingTime] forState:UIControlStateNormal];
    [self.codeButton setTitle:[NSString stringWithFormat:@"%d秒后重发",self.waitingTime] forState:UIControlStateDisabled];
    self.resendButtonTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWaitingTime:) userInfo:nil repeats:YES];
}

- (void)updateWaitingTime:(NSTimer*)timer
{
    self.waitingTime --;
    self.codeButton.titleLabel.text =  [NSString stringWithFormat:@"%d秒后重发",self.waitingTime];
    [self.codeButton setTitle:[NSString stringWithFormat:@"%d秒后重发",self.waitingTime] forState:UIControlStateNormal];
    [self.codeButton setTitle:[NSString stringWithFormat:@"%d秒后重发",self.waitingTime] forState:UIControlStateDisabled];
    if (self.waitingTime <= 0){
        self.codeButton.titleLabel.text = @"获取验证码";
        [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeButton.enabled = YES;
        [self.resendButtonTimer invalidate];
        self.resendButtonTimer = nil;
    }
}

- (IBAction)loginAct:(UIButton *)sender {
    if (self.phone.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请填写手机号码"];
        return;
    }
    NSDictionary *dict = @{@"phone":self.phone.text,
                           @"captcha":self.code.text};
    [SVProgressHUD show];
    NSString *method = @"act=connect&op=check_sms_captcha";
    if (_isBandMail) {
        method = @"act=connect&op=identityEmailCode";
        dict = @{@"email":self.phone.text,
                               @"auth_code":self.code.text};
    }
    [HTTPClientInstance postMethod:method params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [AlertHelper showAlertWithTitle:@"验证成功"];
            [self.navigationController popViewControllerAnimated:YES];
            self.bandPhone(self.phone.text);
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)checkBand
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=connect&op=checkMobile" params:@{@"phone":self.phone.text} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            if (dict.count>0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"该手机号已经注册，是否放弃该手机号所注册的账号" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self sendPhoneCode];
                }];
                UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:act1];
                [alert addAction:act2];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
                [self sendPhoneCode];
            }
        }
        else{
        }
    }];
}

- (void)sendPhoneCode
{
    [SVProgressHUD show];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSString *method = @"act=connect&op=get_sms_captcha";
    if (_isBandMail) {
        method = @"act=connect&op=sendEmailCode";
        [dict setObject:self.phone.text forKey:@"email"];
    }
    else{
        [dict setObject:self.phone.text forKey:@"phone"];
    }
    [HTTPClientInstance postMethod:method params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self startWaitingTime];
        }
        else{
            [AlertHelper showAlertWithDict:data];
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
