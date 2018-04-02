//
//  NewsCell.m
//  News
//
//  Created by ye jiawei on 2017/11/2.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "NewsCell.h"
#import "Ad.h"
#import "UIImage+ChangeColor.h"
#import "WebViewController.h"
#import "PhotoBrowser.h"
#define spaceTop     36+18//self.bgView.top+self.content.top
#define spaceTwoLabel    24
#define spaceMiddle 5
#define spaceBottom 10
#define spaceOutside 10

#define titleHeight 59
#define view1Height 38
#define view2Height 80//137
#define imageHeight 128

#define imageRadio (50.0/19.0)//广告宽高比
#define adImageHeight (ScreenWidth-64)/imageRadio
#define adViewHeigh adImageHeight+32

@interface NewsCell()
@property (weak, nonatomic) IBOutlet UIView *comView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *pointImage;
@property (weak, nonatomic) IBOutlet UIView *leftLine;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *lines;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UIButton *picBt;
@property (weak, nonatomic) IBOutlet UIView *countView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *adBtn;

@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@property (weak, nonatomic) IBOutlet UILabel *showTop;

@end

@implementation NewsCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.comView.layer.cornerRadius = self.comView.height/2.0f;
    self.comView.layer.masksToBounds = YES;
    self.title.font = [NewsCell font];
    self.content.font = [NewsCell font];
    UIImage *image = [UIImage imageNamed:@"comment"];
    UIImage *image1 = [image imageWithColor:ThemeColor];
    [self.likeBtn setImage:image1 forState:UIControlStateSelected];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    for (UIView *view in self.lines) {
        view.height = 0.5;
    }
    [self themeColorChange];
    self.adBtn.titleLabel.numberOfLines = 0;
    self.showTop.textColor = ThemeColor;
    self.showTop.layer.cornerRadius = self.showTop.height/2.0;
    self.showTop.layer.borderColor = ThemeColor.CGColor;
    self.showTop.layer.borderWidth = 0.5;
    self.adImage.height = adImageHeight;
    self.adView.height = adViewHeigh;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}

- (IBAction)picTap:(UIButton *)sender {
    PhotoBrowser* browser = [[PhotoBrowser alloc] initWithBigImageInfos:@[self.news.news_pic] smallImageInfos:@[self.news.news_pic] imageIndex:0 delegate:self];
    [browser show];
}

+ (CGFloat)cellHeight:(NewsObject *)news
{
    BOOL isSpread = news.isSpread;
    if (isSpread) {
        CGFloat imageH = 0;
        CGFloat adHeigh = 0;
        if (news.news_pic.length > 0) {
            imageH = imageHeight + spaceMiddle;
        }
        if (news.ad) {
            adHeigh = adViewHeigh;
        }
        NSString *ad = [NSString stringWithFormat:@"广告 %@",news.textAD.text];
        NSString *title = news.news_title;
        NSString *content = news.news_content;
        CGFloat height1 = [NewsCell getSpaceLabelHeight:title withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        CGFloat height0 = [self getSpaceLabelHeight:content withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        CGSize size = CGSizeZero;
        if ( news.textAD.text.length > 0) {
           size = [Tool sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake((ScreenWidth-(320-255)), MAXFLOAT) string:ad];
        }
        CGFloat height = spaceTop +height0 + spaceMiddle + spaceBottom + view2Height + height1 + spaceOutside + spaceTwoLabel + imageH + size.height + spaceMiddle + adHeigh;
        return height;
    }
    else{
        CGFloat adHeigh = 0;
        if (news.ad) {
            adHeigh = adViewHeigh;
        }
        NSString *title = news.news_title;
        CGFloat height1 = [NewsCell getSpaceLabelHeight:title withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        CGFloat height = spaceTop + spaceMiddle + spaceBottom + view1Height + height1 + spaceOutside + adHeigh;
        return height;
    }
}

+ (UIFont*)font
{
    return defaultSizeFont(17);
}

+ (UIFont*)titleFont
{
    return blodSizeFont(17);
}

- (void)setlabelFont{
    self.content.font = [NewsCell font];
    self.timeLabel.font = defaultSizeFont(12);
    self.adTime.font = defaultSizeFont(12);
    self.editor.font = defaultSizeFont(14);
    self.tipLabel1.font = defaultSizeFont(14);
    self.tipLabel2.font = defaultSizeFont(14);
    self.tipLabel3.font = defaultSizeFont(14);
    self.tipLabel4.font = defaultSizeFont(12);
}

- (void)setNews:(NewsObject *)news
{
    _news = news;
    BOOL isSpread = news.isSpread;
    self.showTop.hidden = !news.news_top;
    double time = [news.news_showtime doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    self.timeLabel.text = timeString;
    self.adTime.text = timeString;
    self.editor.text = [NSString stringWithFormat:@"编辑:%@",news.news_uname];
    self.collectBtn.selected = news.collected;
//    self.likeBtn.selected = news.likenew;
    self.countView.hidden = news.news_commentnum == 0;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",news.news_commentnum];
    self.adBtn.hidden = YES;
    [self setlabelFont];
    if (isSpread) {
        self.leftLine.backgroundColor = RGBA(223,48,49,1);
        self.title.font = [NewsCell titleFont];
        self.pointImage.image = [UIImage imageNamed:@"bigpoint"];
        self.view2.hidden = NO;
        self.view1.hidden = YES;
        self.content.hidden = NO;
        self.line.hidden = NO;
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentLeft;
        CGFloat labelsize = [ThemeManager instance].textFont*2+17;
        paraStyle.lineSpacing = labelsize * 0.3;
        NSDictionary *dic = @{NSFontAttributeName:[NewsCell titleFont], NSParagraphStyleAttributeName:paraStyle
                              };
        NSString *title = news.news_title;
        NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc]initWithString:title attributes:dic];
        CGFloat height1 = [NewsCell getSpaceLabelHeight:title withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        self.title.text = title;
        self.title.attributedText = title1;
        self.title.height = height1;//size0.height;
        self.line.top = self.title.bottom + 11;
        self.content.top = self.title.bottom + spaceTwoLabel;
        NSString *content = news.news_content;
        NSDictionary *dic1 = @{NSFontAttributeName:[NewsCell font], NSParagraphStyleAttributeName:paraStyle
                              };
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:content attributes:dic1];
        //self.content.text = content;
        self.content.attributedText = string;
        CGFloat height = [NewsCell getSpaceLabelHeight:content withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        self.content.height = height;
        if (news.news_pic.length == 0) {
            self.picView.hidden = YES;
            self.picBt.hidden = YES;
            self.view2.top = self.content.bottom + spaceMiddle;
            self.bgView.height = self.view2.bottom + spaceBottom;
        }
        else{
            self.picView.hidden = NO;
            self.picBt.hidden = NO;
            [self.picView sd_setImageWithURL:[NSURL URLWithString:news.news_pic]];
            self.picView.top = self.content.bottom + spaceMiddle;
            self.picBt.top = self.content.bottom + spaceMiddle;
            self.view2.top = self.picView.bottom + spaceMiddle;
            self.bgView.height = self.view2.bottom + spaceBottom;
        }
        self.timeLabel.textColor = ThemeColor;
        NSString *ad_text = [NSString stringWithFormat:@"广告 %@",news.textAD.text];
        if (news.textAD.text.length == 0) {
            self.adBtn.hidden = YES;
        }
        else{
            self.adBtn.hidden = NO;
            CGSize size = [Tool sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake((ScreenWidth-(320-255)), MAXFLOAT) string:ad_text];
            //[self.adBtn setTitle:ad_text forState:UIControlStateNormal];
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc]initWithString:@"广告 " attributes:@{NSForegroundColorAttributeName:RGB(203, 203, 203),NSFontAttributeName:[UIFont systemFontOfSize:15]}];
            NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc]initWithString:news.textAD.text attributes:@{NSForegroundColorAttributeName:RGB(153, 153, 153),NSFontAttributeName:[UIFont systemFontOfSize:15]}];
            [att1 appendAttributedString:att2];
            [self.adBtn setAttributedTitle:att1 forState:UIControlStateNormal];
            self.adBtn.height = size.height;
            self.adBtn.top = self.bgView.bottom + spaceMiddle;
        }
    }
    else{
        self.leftLine.backgroundColor = RGBA(223,48,49,0.4);
        self.title.font = [NewsCell font];
        self.pointImage.image = [UIImage imageNamed:@"smallpoint"];
        self.view1.hidden = NO;
        self.view2.hidden = YES;
        self.picView.hidden = YES;
        self.picBt.hidden = YES;
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentLeft;
        CGFloat labelsize = [ThemeManager instance].textFont*2+17;
        paraStyle.lineSpacing = labelsize * 0.3;
        NSDictionary *dic = @{NSFontAttributeName:[NewsCell font], NSParagraphStyleAttributeName:paraStyle
                              };
        NSString *title = news.news_title;
        NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc]initWithString:title attributes:dic];
        self.title.text = title;
        self.title.attributedText = title1;
        CGFloat height1 = [NewsCell getSpaceLabelHeight:title withFont:[NewsCell font] withWidth:(ScreenWidth-(320-237))];
        self.title.height = height1;//size.height;
        self.title.text = title;
        self.view1.top = self.title.bottom + spaceMiddle;
        self.bgView.height = self.view1.bottom + spaceBottom;
        self.content.hidden = YES;
        self.line.hidden = YES;
        self.timeLabel.textColor = RGB(102, 102, 102);
    }
    if (news.ad) {
        CGFloat cellHeight = [NewsCell cellHeight:news];
        self.adView.hidden = NO;
        self.adView.bottom = cellHeight;
        [self.adImage sd_setImageWithURL:[NSURL URLWithString:news.ad.pic]];
    }
    else{
        self.adView.hidden = YES;
    }
    [self themeColorChange];
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme) {
        self.title.textColor = self.news.news_red ? ThemeColorLight : TextColor1Light;
        self.content.textColor = self.news.news_red ? ThemeColorLight : TextColor1Light;
        self.tipLabel1.textColor = TextColor2Light;
        self.tipLabel2.textColor = TextColor2Light;
        self.tipLabel3.textColor = TextColor2Light;
        self.editor.textColor = TextColor2Light;
        self.bgView.backgroundColor = RGB(42,41,47);
        self.comView.backgroundColor = LightBackgroundColor;
        self.contentView.backgroundColor = LightBackgroundColor;
        for (UIView *view in self.lines) {
            view.backgroundColor = RGBA(255, 255, 255, 0.08);
        }
    }
    else{
        self.contentView.backgroundColor = DayBackgroundColor;
        self.comView.backgroundColor = DayBackgroundColor;
        self.title.textColor = self.news.news_red ? ThemeColor : TextColor1;
        self.content.textColor = self.news.news_red ? ThemeColor : TextColor1;
        self.tipLabel1.textColor = TextColor2;
        self.tipLabel2.textColor = TextColor2;
        self.tipLabel3.textColor = TextColor2;
        self.editor.textColor = TextColor2;
        self.bgView.backgroundColor = [UIColor whiteColor];
        for (UIView *view in self.lines) {
            view.backgroundColor = RGBA(229, 229, 229, 1);
        }
    }
}

- (IBAction)writeComment:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationComment object:nil userInfo:@{@"data":self.news}];
}

- (IBAction)collectNews:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCollect object:nil userInfo:@{@"data":self.news,@"cell":self}];
}

- (IBAction)shareNews:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShare object:nil userInfo:@{@"data":self.news}];
}
- (IBAction)likeNews:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLike object:nil userInfo:@{@"data":self.news,@"cell":self}];
}

- (IBAction)reward:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReward object:nil userInfo:@{@"data":self.news}];
}

- (IBAction)reportNews:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReport object:nil userInfo:@{@"data":self.news}];
}
- (IBAction)gotoAd:(UIButton *)sender {
    if (self.news.textAD.url.length == 0) {
        return;
    }
    WebViewController *vc = [[WebViewController alloc]init];
    vc.url = self.news.textAD.url;
    vc.ad = self.news.textAD;
    UITabBarController *tab = (UITabBarController*)AppDelegateInstance.window.rootViewController;
    UINavigationController *navi = tab.selectedViewController;
    [navi pushViewController:vc animated:YES];
    [HTTPClientInstance postMethod:@"act=advertise&op=adclick" params:@{@"advertiseid":@(self.news.textAD.adID),@"type":@"flow"} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
        }
        else{
        }
    }];
}
- (IBAction)gotoImgAd:(UIButton *)sender {
    if (self.news.ad.url.length == 0) {
        return;
    }
    WebViewController *vc = [[WebViewController alloc]init];
    vc.url = self.news.ad.url;
    vc.ad = self.news.ad;
    UITabBarController *tab = (UITabBarController*)AppDelegateInstance.window.rootViewController;
    UINavigationController *navi = tab.selectedViewController;
    [navi pushViewController:vc animated:YES];
    [HTTPClientInstance postMethod:@"act=advertise&op=adclick" params:@{@"advertiseid":@(self.news.ad.adID),@"type":@"flow"} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
        }
        else{
        }
    }];
}

+(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    CGFloat labelsize = [ThemeManager instance].textFont*2+17;
    paraStyle.lineSpacing = labelsize * 0.3;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

@end
