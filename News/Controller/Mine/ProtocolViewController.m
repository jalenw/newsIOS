//
//  PrococolViewController.m
//  News
//
//  Created by ye on 2017/12/9.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "ProtocolViewController.h"

@interface ProtocolViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"协议";
    [self getProtocol];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProtocol
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=news&op=base" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSString *xieyi = [dict safeStringForKey:@"xieyi"];
            self.textView.text = xieyi;
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
