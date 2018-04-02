//
//  LoginViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/13.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"

@interface LoginViewController ()<UITextFieldDelegate>
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

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"手机登录";
    [self setupForDismissKeyboard];
    self.contentView.layer.borderWidth = 0.5;
    self.line.height = 0.5;
    self.line.top = 47.5;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.loginButton.backgroundColor = text.length == 0 ? RGB(163, 163, 163) : ThemeColor;
    self.loginButton.enabled = text.length == 0 ? NO : YES;
    if (textField == self.phone && text.length > 11) {
        return NO;
    }
    return YES;
}
- (IBAction)sendCode:(UIButton *)sender {
    if (self.phone.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入手机号"];
        return;
    }
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=connect&op=get_sms_captcha" params:@{@"phone":self.phone.text} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self startWaitingTime];
            [self.code becomeFirstResponder];
        }
        else{
            [AlertHelper showAlertWithTitle:@"发送短信失败"];
        }
    }];
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
    [HTTPClientInstance postMethod:@"act=login&op=captchaLogin" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [HTTPClientInstance setUid:[dict safeStringForKey:@"member_id"] token:[dict safeStringForKey:@"key"]];
            User *user = [User mj_objectWithKeyValues:dict];
            AppDelegateInstance.defaultUser = user;
            [self.navigationController popViewControllerAnimated:YES];
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
