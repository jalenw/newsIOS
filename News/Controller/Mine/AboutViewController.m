//
//  AboutViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/21.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *botton2;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_isAbout) {
        self.title = @"关于我们";
    }
    else{
        self.title = @"商务合作";
    }
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=base" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            [self.image sd_setImageWithURL:[NSURL URLWithString:[dict safeStringForKey:@"lolo"]]];
            if (_isAbout) {
                self.content.text = [dict safeStringForKey:@"aboutus"];
                [self.button1 setTitle:[dict safeStringForKey:@"aboutphone"] forState:UIControlStateNormal];
                [self.botton2 setTitle:[dict safeStringForKey:@"abouttel"] forState:UIControlStateNormal];
            }else{
                self.content.text = [dict safeStringForKey:@"contactus"];
                [self.button1 setTitle:[dict safeStringForKey:@"swphone"] forState:UIControlStateNormal];
                [self.botton2 setTitle:[dict safeStringForKey:@"swtel"] forState:UIControlStateNormal];
            }
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (IBAction)call:(UIButton *)sender {
    NSString *phone = sender.titleLabel.text;
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
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

