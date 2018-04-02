//
//  AdvertisementViewController.m
//  zingchat
//
//  Created by noodle on 15/11/13.
//  Copyright (c) 2015年 Miju. All rights reserved.
//

#import "AdvertisementViewController.h"
#import "UIImageView+WebCache.h"
@interface AdvertisementViewController ()
{
    NSTimer *timer;
    int count;
    CGFloat originY;
}
@end

@implementation AdvertisementViewController

- (void)dealloc
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = ScreenBounds;
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = 10;
    count=3;
    [self.button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target: self selector: @selector(dissmissView) userInfo: nil repeats: YES];
    
    self.tipImg.animationImages = [NSArray arrayWithObjects:[UIImage  imageNamed:@"leftMenuBt0"],[UIImage imageNamed:@"leftMenuBt1"],[UIImage imageNamed:@"leftMenuBt2"],[UIImage  imageNamed:@"leftMenuBt3"],[UIImage imageNamed:@"leftMenuBt4"],[UIImage imageNamed:@"leftMenuBt5"],[UIImage imageNamed:@"leftMenuBt6"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],[UIImage  imageNamed:@"leftMenuBt0"],nil];
    [self.tipImg setAnimationDuration:3];
    [self.tipImg setAnimationRepeatCount:MAXFLOAT];
    [self.tipImg startAnimating];
}

-(void)dissmissView
{
    if (count==0) {
        [self.advertisementViewDelegate AdvertisementDismiss];
        [self.view removeFromSuperview];
    }
    [self.button setTitle:[NSString stringWithFormat:@"跳过%ds",count] forState:UIControlStateNormal];
    count--;
}

-(void)setupAdvertisement:(NSString*)pic withUrl:(NSString*)url
{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    if (pic) {
        UIImage *img = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pic]]];
        imgView.image = img;
        [self.view addSubview:imgView];
        [self.view addSubview:self.tipImg];
        UIButton *bgBt = [UIButton buttonWithType:UIButtonTypeCustom];
        bgBt.frame = imgView.frame;
        [bgBt addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bgBt];
        [self.view addSubview:self.button];
    }
    self.url = url;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point=[touch locationInView:AppDelegateInstance.window];
    originY = point.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point=[touch locationInView:AppDelegateInstance.window];
    CGFloat i = point.y - originY;
    if (i<0) {
        self.view.top = i;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point=[touch locationInView:AppDelegateInstance.window];
    CGFloat i = point.y - originY;
    if (i == 0) {
        [self bgButtonClicked];
    }
    else if (self.view.top<-ScreenHeight/3) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.bottom = 0;
        } completion:^(BOOL finished) {
            [self buttonClicked];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.top = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [self.advertisementViewDelegate AdvertisementDismiss];
    [self.view removeFromSuperview];
}

-(void)bgButtonClicked
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [HTTPClientInstance postMethod:@"act=advertise&op=adclick" params:@{@"advertiseid":self.news_id,@"type":@"start"} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
        }
        else{
        }
    }];
    
    [self.advertisementViewDelegate AdvertisementClicked:self.url];
}
@end
