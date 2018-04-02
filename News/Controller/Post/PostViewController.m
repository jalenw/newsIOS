//
//  PostViewController.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "PostViewController.h"
#import "CustomPickerView.h"
#import "UIButton+WebCache.h"
#import "DraftViewController.h"
#import "BecomeEditorViewController.h"
#import "User.h"

@interface PostViewController ()<UITextViewDelegate, CustomPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel2;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property (weak, nonatomic) IBOutlet UIButton *collect;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UIButton *addImage;
@property (weak, nonatomic) IBOutlet UIButton *redbutton;
@property (weak, nonatomic) IBOutlet UITextField *channelField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *topViewLine;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSDictionary *channel;
@property (nonatomic, strong) NSDate *postDate;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupForDismissKeyboard];
    if (self.news) {
        self.title = @"详情";
        self.params = [[NSMutableDictionary alloc]init];
        self.collect.right = ScreenWidth - 20;
        self.send.right = ScreenWidth - 20;
        [self setupNewsView];
        if (self.simpleModel) {
            CGFloat tabbarHeight = kDevice_Is_iPhoneX ? 83 : 49;
            self.inputView.height = ScreenHeight - 50 - (182-99) - NavigationAndStatusBarHeight;
            self.redbutton.hidden = YES;
        }
        else{
            self.inputView.height = ScreenHeight - 50 - 182 - 10 - NavigationAndStatusBarHeight;
            self.redbutton.hidden = NO;
        }
    }
    else{
        [self setNavi];
        self.collect.right = ScreenWidth - 20;
        self.send.right = ScreenWidth - 132;
        self.params = [[NSMutableDictionary alloc]init];
        self.collect.layer.borderWidth = 0.5;
        self.collect.layer.borderColor = RGBA(92, 93, 98, 1).CGColor;
        if (self.simpleModel) {
            CGFloat tabbarHeight = kDevice_Is_iPhoneX ? 83 : 49;
            self.inputView.height = ScreenHeight - 50 - (182-99) - NavigationAndStatusBarHeight - tabbarHeight;
            self.redbutton.hidden = YES;
        }
        else{
            self.title = @"添加资讯";
            self.inputView.height = ScreenHeight - 50 - 182 - 10 - NavigationAndStatusBarHeight;
            self.redbutton.hidden = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([AlertHelper checkLogin:nil]) {
        if (!HTTPClientInstance.isLogin || (AppDelegateInstance.defaultUser.member_type==0)) {
            [self showIdentifyView];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitleLabelHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNewsView
{
    self.titleLabel.text = [self.news safeStringForKey:@"new_title"];
    self.textView.text = [self.news safeStringForKey:@"new_content"];
    double createtime = [self.news safeDoubleForKey:@"new_createtime"];
    double new_publictime = [self.news safeDoubleForKey:@"new_publictime"];
    double time = new_publictime;//MAX(createtime, new_publictime);
    self.postDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日HH时mm分"];
    _timeField.text = [dateFormatter stringFromDate:self.postDate];
    _channelField.text = [self.news safeStringForKey:@"new_channelname"];
    if ([self.news safeStringForKey:@"new_pic"].length>0) {
        [self.addImage sd_setImageWithURL:[NSURL URLWithString:[self.news safeStringForKey:@"new_pic"]] forState:UIControlStateNormal];
    }
    self.channel = @{@"channel_id":[self.news safeStringForKey:@"new_channelid"],
                     @"channel_content":[self.news safeStringForKey:@"new_channelname"]
                     };
    self.redbutton.selected = [[self.news safeStringForKey:@"new_red"] boolValue];
    self.collect.hidden = YES;
    self.placeHolderLabel.hidden = YES;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)self.titleLabel.text.length];
    self.countLabel2.text = [NSString stringWithFormat:@"%lu/200",(unsigned long)self.textView.text.length];
    [self.params addEntriesFromDictionary:self.news];
}

- (void)setNavi{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"草稿箱" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoDraftBox) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

- (void)gotoDraftBox{
    DraftViewController *vc = [[DraftViewController alloc]init];
    vc.type = self.simpleModel ? @"tips" : @"news";
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (textView == self.titleLabel) {
        self.countLabel.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)string.length];
        [self setTitleLabelHeight];
        return YES;
    }
    self.placeHolderLabel.hidden = string.length != 0;
    if (string.length > 1000) {
        [AlertHelper showAlertWithTitle:@"内容长度超过限制"];
    }
    self.countLabel2.text = [NSString stringWithFormat:@"%lu/200",(unsigned long)string.length];
    return YES;
}

- (IBAction)selectSendDate:(UIButton *)sender {
    CustomPickerView *picker = [CustomPickerView datePickerView:UIDatePickerModeDateAndTime];
    picker.delegate = self;
    [picker showPicker];
}

- (IBAction)highRed:(UIButton *)sender {
    self.redbutton.selected = !self.redbutton.selected;
}

- (IBAction)selectChannel:(UIButton *)sender {
    CustomPickerView *picker = [CustomPickerView customPickerWithChannel];
    picker.delegate = self;
}

- (void)customPickerViewDidSelected:(CustomPickerView *)view customDict:(NSDictionary *)dict
{
    NSDictionary *dic = [dict safeDictionaryForKey:@"0"];
    self.channel = dic;
    self.channelField.text = [dic safeStringForKey:@"channel_content"];
}

- (void)customPickerViewDidSelected:(CustomPickerView *)view date:(NSDate *)date dateString:(NSString *)dateString
{
    self.postDate = date;
    self.timeField.text = dateString;
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
    self.image = image;
    [self.addImage setImage:image forState:UIControlStateNormal];
}

- (IBAction)addNews:(UIButton *)sender {
    if (!HTTPClientInstance.isLogin || (AppDelegateInstance.defaultUser.member_type==0)) {
        [self showIdentifyView];
        return;
    }
    if (self.titleLabel.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入标题"];
        return;
    }
    if (self.titleLabel.text.length > 55) {
        [AlertHelper showAlertWithTitle:@"标题长度超过限制"];
        return;
    }
    if (self.textView.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入详细内容"];
        return;
    }
    if (self.textView.text.length > 1000) {
        [AlertHelper showAlertWithTitle:@"内容长度超过限制"];
        return;
    }
    [self.params setObject:self.titleLabel.text forKey:@"new_title"];
    [self.params setObject:self.textView.text forKey:@"new_content"];
    [self.params setObject:@(sender.tag) forKey:@"new_draft"];
    [self.params setObject:@(self.redbutton.selected) forKey:@"new_red"];
    if (self.simpleModel) {
        [self.params setObject:@"tips" forKey:@"type"];
    }
    else{
        [self.params setObject:@"news" forKey:@"type"];
        if (self.channelField.text.length == 0) {
            [AlertHelper showAlertWithTitle:@"请选择栏目"];
            return;
        }
        [self.params setObject:[self.channel safeObjectForKey:@"channel_id"] forKey:@"channel_id"];
        [self.params setObject:[self.channel safeObjectForKey:@"channel_id"] forKey:@"new_channelid"];
    }
    if (self.postDate) {
        [self.params setObject:[NSNumber numberWithDouble:[self.postDate timeIntervalSince1970]] forKey:@"new_publictime"];
    }
    if (self.isCheck) {
        [self.params setObject:@1 forKey:@"new_allow"];
        [self showRecommend];
        return;
    }
    [self uploadData];
}

- (void)uploadData
{
    [self uploadAvatar:^{
        [SVProgressHUD show];
        NSString *method = self.news ? @"act=news&op=editNews" : @"act=news&op=addNews";
        [HTTPClientInstance postMethod:method params:self.params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
            [SVProgressHUD dismiss];
            if (code == 200) {
                if ([[self.params safeStringForKey:@"type"] isEqualToString:@"tips"] && [self.params safeIntForKey:@"new_draft"]==0 && [self.params safeIntForKey:@"new_allow"] != 1) {
                    [MobClick event:@"baoliao"];
                }
                [AlertHelper showAlertWithTitle:@"操作成功"];
                [self resetView];
                if (!_isNavi) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else{
                [AlertHelper showAlertWithDict:data];
            }
        }];
    }];
}

- (void)showRecommend
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否添加到推荐" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.params setObject:@1 forKey:@"new_hot"];
        [self uploadData];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uploadData];
    }];
    [alert addAction:act1];
    [alert addAction:act2];
    [self presentViewController:alert animated:YES completion:nil];
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
            [self.params setObject:[dict safeStringForKey:@"thumb_name"] forKey:@"new_pic"];
            block();
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}
- (IBAction)clickTitle:(UIButton *)sender {
    [self.titleLabel becomeFirstResponder];
}

- (void)resetView{
    self.textView.text = nil;
    self.placeHolderLabel.hidden = NO;
    self.titleLabel.text = nil;
    self.countLabel.text = @"0/30";
    self.countLabel2.text = @"0/200";
    self.image = nil;
    [self.addImage setImage:nil forState:UIControlStateNormal];
    self.postDate = nil;
    self.timeField.text = nil;
    self.channel = nil;
    self.channelField.text = nil;
    self.redbutton.selected = NO;
    [self.params removeAllObjects];
}

- (void)showIdentifyView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先实名认证再进行操作" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"去认证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BecomeEditorViewController *vc = [[BecomeEditorViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:act1];
    [alert addAction:act2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setTitleLabelHeight
{
    CGFloat defaultTitleHeight = self.titleLabel.height;
    CGFloat defaultTopViewHeight = self.topView.height;
    CGFloat inputHeight = self.inputView.height;
    CGFloat titleContentHeight = self.titleLabel.contentSize.height;
    CGFloat less = titleContentHeight - defaultTitleHeight;
    self.titleLabel.height = self.titleLabel.contentSize.height;
    self.topView.height = defaultTopViewHeight + less;
    self.topViewLine.bottom = self.topView.height;
    self.inputView.top = self.topView.bottom;
    self.inputView.height = inputHeight - less;
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
