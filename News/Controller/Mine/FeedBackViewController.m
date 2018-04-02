//
//  FeedBackViewController.m
//  News
//
//  Created by Innovation on 17/11/19.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *aView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel2;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIView *phoneView;

@property (strong, nonatomic) UIImage *image;
@property (nonatomic, strong) NSMutableDictionary *params;
@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    [self setupForDismissKeyboard];
    self.params = [[NSMutableDictionary alloc]init];
    if (_news_id) {
        self.phoneView.hidden = YES;
        self.placeHolderLabel.text = @"举报内容";
        self.title = @"举报";
    }
    //[self setNavi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavi{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmAct) forControlEvents:UIControlEventTouchUpOutside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

- (void)confirmAct
{
    
}

- (IBAction)send:(UIButton *)sender {
    if (self.textView.text.length == 0) {
        NSString *string = @"请输入您的意见反馈";
        if (_news_id) {
            string = @"请输入您的举报内容";
        }
        [AlertHelper showAlertWithTitle:string];
        return;
    }
    if (self.textView.text.length > 200) {
        [AlertHelper showAlertWithTitle:@"输入文字超出限制"];
        return;
    }
    NSString *content = @"feedback_content";
    NSString *method = @"act=news&op=addFeedback";
    if (_news_id) {
        content = @"accusation_content";
        method = @"act=news&op=addAccusation";
    }
    [self.params setObject:self.textView.text forKey:content];
    [self.params setValue:self.phoneField.text forKey:@"feedback_mobile"];
    [self.params setValue:self.news_id forKey:@"new_id"];
    [self uploadAvatar:^{
        [SVProgressHUD show];
        [HTTPClientInstance postMethod:method params:self.params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
            [SVProgressHUD dismiss];
            if (code == 200) {
                if (self.news_id) {
                    [MobClick event:@"report" label:[NSString stringWithFormat:@"%@",self.news_id]];
                }
                [AlertHelper showAlertWithTitle:@"提交成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [AlertHelper showAlertWithDict:data];
            }
        }];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.placeHolderLabel.hidden = string.length != 0;
    self.countLabel2.text = [NSString stringWithFormat:@"%lu/200",(unsigned long)string.length];
    return YES;
}

- (IBAction)selectImage:(UIButton *)sender {
    UIImagePickerController *vc = [[UIImagePickerController alloc]init];
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.addImageBtn setImage:image forState:UIControlStateNormal];
}
- (IBAction)beginEdit:(UITextField *)sender {
    self.aView.top = -100;
}
- (IBAction)endEdit:(id)sender {
    self.aView.top = 0;
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
            NSString *pic = @"new_pic";
            if (_news_id) {
                pic = @"accusation_pic";
            }
            [self.params setObject:[dict safeStringForKey:@"thumb_name"] forKey:pic];
            block();
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
