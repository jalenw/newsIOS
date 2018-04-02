//
//  CommentViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/6.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "CommentViewController.h"
#import "LoginView.h"
#import "CommentCell.h"
#import "Comment.h"

@interface CommentViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CommentCellDelegate>
{
    BOOL recommendSuccess;
}
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *sendbutton;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *spreadCell;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) Comment *replyComment;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupForDismissKeyboard];
    [self themeColorChange];
    self.sendbutton.layer.cornerRadius = cornerRadiusWidth;
    self.sendbutton.layer.masksToBounds = YES;
    self.sendbutton.layer.borderColor = RGB(102, 102, 102).CGColor;
    self.sendbutton.layer.borderWidth = 0.5;
    [self getCommentList];
    self.tableView.estimatedRowHeight = 212;
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme) {
        self.bgView.backgroundColor = LightBackgroundColor;
        self.tableView.backgroundColor = LightBackgroundColor;
    }
    else{
        self.bgView.backgroundColor = DayBackgroundColor;
        self.tableView.backgroundColor = DayBackgroundColor;
    }
}

- (void)getCommentList
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=getAllComment" params:@{@"new_id":self.news_id} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            [Comment mj_setupObjectClassInArray:^NSDictionary *{
                return @{@"subComment":@"Comment"};
            }];
            self.data = [Comment mj_objectArrayWithKeyValuesArray:array];
            [self.tableView reloadData];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)close:(UIButton *)sender {
    [self.view removeFromSuperview];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [AlertHelper checkLogin:self];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.placeHolderLabel.hidden = string.length != 0;
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.replyComment ? 2 : 0;
    }
    return self.data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:identify owner:self options:nil][0];
        cell.delegate = self;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.comment = self.replyComment;
            return cell;
        }
        return self.spreadCell;
    }
    Comment *comment = [self.data objectAtIndex:indexPath.row];
    cell.comment  = comment;
    return cell;
}

- (void)reply:(Comment *)comment
{
    if (self.replyComment) {
        [self.data addObject:self.replyComment];
    }
    [self.textView becomeFirstResponder];
    self.replyComment = comment;
    [self.data removeObject:comment];
    [self sortData];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)sortData{
    [self.data sortUsingSelector:@selector(compare:)];
}
- (IBAction)send:(UIButton *)sender {
    if (self.textView.text.length == 0) {
        [AlertHelper showAlertWithTitle:@"请输入回复内容"];
        return;
    }
    [self.view endEditing:YES];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.news_id forKey:@"new_id"];
    [dict setObject:self.textView.text forKey:@"reply_content"];
    if (self.replyComment) {
        [dict setObject:@(self.replyComment.comment_id) forKey:@"r_id"];
    }
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=addComment" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            if (self.replyComment) {
                [self.data addObject:self.replyComment];
                self.replyComment = nil;
            }
            recommendSuccess = YES;
            [self refreshComment];
            [MobClick event:@"comment"];
        }
        else{
            [AlertHelper showAlertWithDict:data controller:self];
        }
    }];
}

- (void)refreshComment
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=getAllComment" params:@{@"new_id":self.news_id} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        self.textView.text = nil;
        if (code == 200) {
            if (recommendSuccess) {
                [AlertHelper showAlertWithTitle:@"评论成功"];
                recommendSuccess = NO;
            }
            NSArray *array = [data safeArrayForKey:@"datas"];
            [Comment mj_setupObjectClassInArray:^NSDictionary *{
                return @{@"subComment":@"Comment"};
            }];
            self.data = [Comment mj_objectArrayWithKeyValuesArray:array];
            [self.tableView reloadData];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!HTTPClientInstance.isLogin) {
        [self showIdentifyView];
        [self.view endEditing:YES];
    }
}

- (void)showIdentifyView
{
    NSDictionary *dict = @{@"code":@404};
    [AlertHelper showAlertWithDict:dict controller:self];
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
