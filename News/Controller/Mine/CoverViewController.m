//
//  CoverViewController.m
//  News
//
//  Created by ye jiawei on 2017/11/22.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "CoverViewController.h"
#import "WebViewController.h"

@interface CoverViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;

@property (nonatomic, strong) NSArray *data;

@end

@implementation CoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"新闻封面";
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=advertise" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            self.data = [data safeArrayForKey:@"datas"];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)setData:(NSArray *)data
{
    _data = data;
    NSArray *array = @[self.image1,self.image2,self.image3,self.image4];
    for (int i = 0; i < data.count && i < array.count; i++) {
        NSDictionary *dict = data[i];
        UIImageView *imageView = array[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[dict safeStringForKey:@"advertise_address"]]];
    }
}

- (IBAction)imageClick:(UIButton *)sender {
    if (self.data.count < sender.tag) {
        return;
    }
    NSDictionary *dict = _data[sender.tag];
    NSString *url = [dict safeStringForKey:@"advertise_url"];
    WebViewController *vc = [[WebViewController alloc]init];
    vc.url = url;
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
