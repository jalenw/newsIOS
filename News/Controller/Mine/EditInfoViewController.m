//
//  EditInfoViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/16.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "EditInfoViewController.h"
#import "UIButton+WebCache.h"
#import "User.h"
#import "BandViewController.h"
#import "BecomeEditorViewController.h"
#import "UIViewController+BackButtonHandler.h"

@interface EditInfoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, BackButtonHandlerProtocol>
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *realname;

@property (nonatomic, strong) UIImage *image;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑资料";
    // Do any additional setup after loading the view from its nib.
    [self setupForDismissKeyboard];
    self.avatarBtn.layer.cornerRadius = self.avatarBtn.width/2.0;
    self.avatarBtn.layer.masksToBounds = YES;
    self.params = [[NSMutableDictionary alloc]init];
    [self setupView];
    [self setNavi];
}

- (void)setupView{
    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:AppDelegateInstance.defaultUser.member_avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.nickname.text = AppDelegateInstance.defaultUser.member_nickname;
    self.phone.text = AppDelegateInstance.defaultUser.member_mobile;
    self.email.text = AppDelegateInstance.defaultUser.member_email;
    self.realname.text = AppDelegateInstance.defaultUser.member_truename;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavi{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

- (BOOL)navigationShouldPopOnBackButton
{
    [self.view endEditing:YES];
    if (self.params.count > 0 || self.image) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否保存已修改的资料" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self finish];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:act1];
        [alert addAction:act2];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (IBAction)changeAvatar:(UIButton *)sender {
    UIImagePickerController *vc = [[UIImagePickerController alloc]init];
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.avatarBtn setImage:image forState:UIControlStateNormal];
    self.image = image;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *key = @"";
    switch (textField.tag) {
        case 0:
            key = @"member_nickname";
            break;
        case 1:
            key = @"member_mobile";
            break;
        case 2:
            key = @"member_email";
            break;
        case 3:
            key = @"member_truename";
            break;
        default:
            break;
    }
    if (text.length != 0) {
        [self.params setObject:text forKey:key];
    }
    else{
        [self.params removeObjectForKey:key];
    }
    return YES;
}

- (void)finish
{
    if (self.params.count > 0 || self.image) {
        [self uploadAvatar:^{
            [self uploadInfo];
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)uploadAvatar:(void(^)(void))block
{
    if (!self.image) {
        block();
        return;
    }
    [SVProgressHUD show];
    [HTTPClientInstance uploadImage:self.image block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            self.image = nil;
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [self.params setObject:[dict safeStringForKey:@"thumb_name"] forKey:@"member_avatar"];
            block();
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)uploadInfo
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=newsuser&op=editUser" params:self.params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            if ([self.params hasObjectForKey:@"member_nickname"]) {
                AppDelegateInstance.defaultUser.member_nickname = [self.params safeStringForKey:@"member_nickname"];
            }
            if ([self.params hasObjectForKey:@"member_avatar"]) {
                AppDelegateInstance.defaultUser.member_avatar = [self.params safeStringForKey:@"member_avatar"];
            }
            if ([self.params hasObjectForKey:@"member_truename"]) {
                AppDelegateInstance.defaultUser.member_truename = [self.params safeStringForKey:@"member_truename"];
            }
            if ([self.params hasObjectForKey:@"member_mobile"]) {
                AppDelegateInstance.defaultUser.member_mobile = [self.params safeStringForKey:@"member_mobile"];
            }
            if ([self.params hasObjectForKey:@"member_email"]) {
                AppDelegateInstance.defaultUser.member_email = [self.params safeStringForKey:@"member_email"];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}
- (IBAction)nameBtn:(id)sender {
    [self.nickname becomeFirstResponder];
}

- (IBAction)phoneBtn:(id)sender {
    if (self.phone.text.length != 0) {
        BecomeEditorViewController *vc = [[BecomeEditorViewController alloc]init];
        vc.realname = ^(NSString *realname, NSString *phone) {
            self.realname.text = realname;
            [self.params setObject:realname forKey:@"member_truename"];
            self.phone.text = phone;
            [self.params setObject:realname forKey:@"member_mobile"];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        BandViewController *vc = [[BandViewController alloc]init];
        vc.bandPhone = ^(NSString *phone) {
            self.phone.text = phone;
            [self.params setObject:phone forKey:@"member_mobile"];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)meaiBtn:(id)sender {
    BandViewController *vc = [[BandViewController alloc]init];
    vc.isBandMail = YES;
    vc.bandPhone = ^(NSString *phone) {
        self.email.text = phone;
        [self.params setObject:phone forKey:@"member_email"];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)realNameBtn:(id)sender {
    if (self.realname.text.length > 0) {
        return;
    }
    BecomeEditorViewController *vc = [[BecomeEditorViewController alloc]init];
    vc.realname = ^(NSString *realname, NSString *phone) {
        self.realname.text = realname;
        [self.params setObject:realname forKey:@"member_truename"];
        self.phone.text = phone;
        [self.params setObject:realname forKey:@"member_mobile"];
    };
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
