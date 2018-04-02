//
//  NewsViewController.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "NewsViewController.h"
#import "ChannelViewController.h"
#import "NewsTabView.h"
#import "TableCell.h"
#import "CommentViewController.h"
#import "NewsObject.h"
#import "SearchViewController.h"
#import "ShareView.h"
#import "JsonHelper.h"
#import "FeedBackViewController.h"
#import "Channel.h"
#import "Ad.h"
#import "VoicePlayer.h"
#import "LabelModel1.h"
#import "LocationService.h"
#import "ListenNews.h"
#import "WebViewController.h"
@interface NewsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, TableCellDelegate>
{
    NSString *productId;
//    BOOL _getlocal;
    dispatch_semaphore_t semaphore;
}
@property (nonatomic, strong) NewsTabView *channelView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *tabData;
@property (nonatomic, strong) NSMutableDictionary *listData;
@property (nonatomic, strong) NSMutableDictionary *imageAdData;
@property (nonatomic, strong) NSMutableDictionary *pageForChannelImageAd;

@property (nonatomic, strong) NSMutableDictionary *textAdData;
@property (nonatomic, strong) NSMutableDictionary *pageForChannelTextAd;
@property (nonatomic, strong) NSMutableDictionary *dataDic;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSArray *like;
@property (nonatomic, strong) NSArray *dislike;

@property (nonatomic, strong) NSArray *channelList;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSDictionary *recommend;

@property (nonatomic, strong) NSDictionary *nowChannel;

@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (strong, nonatomic) IBOutlet UIView *viedoView;
@property (nonatomic) BOOL playStatus;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (nonatomic, strong) NSArray* playViewBg;
@property (weak, nonatomic) IBOutlet UIImageView *playBgView;

//@property (nonatomic, strong) Ad *ad;
//@property (nonatomic, strong) Ad *textAd;

@property (nonatomic, strong) NSMutableDictionary *showData;

@property (nonatomic, strong) NewsObject *rewardNews;
@property (nonatomic, strong) NSNumber *rewardPrice;

@property (strong, nonatomic) IBOutlet UIView *guide0;
@property (strong, nonatomic) IBOutlet UIView *guide1;
@property (strong, nonatomic) IBOutlet UIView *guide2;

//@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) ListenNews *listenManager;

@end

@implementation NewsViewController

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    semaphore = dispatch_semaphore_create(0);
    // Do any additional setup after loading the view from its nib.
    __weak NewsViewController *weakSelf = self;
    self.listenManager = [[ListenNews alloc]init];
    self.listenManager.playFinish = ^(BOOL finish) {
        [AlertHelper showAlertWithTitle:@"当天新闻已播完"];
        weakSelf.playBtn.selected = NO;
        [weakSelf changePlayBg];
    };
    self.listenManager.getVideoAd = ^{
        [weakSelf getVioceAd];
    };
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 309.5, 33.5)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"news_title"];
    UIView *titleView = [[UIView alloc]initWithFrame:imageView.bounds];
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.listData = [[NSMutableDictionary alloc]init];
    self.dataDic = [[NSMutableDictionary alloc]init];
    self.showData = [[NSMutableDictionary alloc]init];
    self.imageAdData = [[NSMutableDictionary alloc]init];
    self.pageForChannelImageAd = [[NSMutableDictionary alloc]init];
    [self.pageForChannelImageAd setValue:@(0) forKey:@"0"];
    self.textAdData = [[NSMutableDictionary alloc]init];
    self.pageForChannelTextAd = [[NSMutableDictionary alloc]init];
     [self.pageForChannelTextAd setValue:@(0) forKey:@"0"];
    [self setupChannelView];
    [self setupCollectionView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(comment:) name:kNotificationComment object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(collect:) name:kNotificationCollect object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(share:) name:kNotificationShare object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(like:) name:kNotificationLike object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(report:) name:kNotificationReport object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reward:) name:kNotificationReward object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(releaseTimer) name:@"kLogoutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    self.timeLabel = [[LabelModel1 alloc]initWithFrame:CGRectMake(0, 0, ScreenHeight, 40)];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = defaultSizeFont(17);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerForRedPoint) userInfo:nil repeats:YES];
    
    self.viedoView.right = ScreenWidth;
    self.viedoView.bottom = ScreenHeight - 49*3;
    [self.view addSubview:self.viedoView];
    
//    [self getAd];
    [self getVioceAd];
//    [self getTextAd];
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    if ([Tool isFirstOpen:@"GuideImage"]) {
        self.guide0.frame = ScreenBounds;
        self.guide1.frame = ScreenBounds;
        self.guide2.frame = ScreenBounds;
        [AppDelegateInstance.window addSubview:self.guide0];
    }

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    [self showNewsDetail];
    [self showAdUrl];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self showNewsDetail];
}

-(void)showNewsDetail
{
    if ([AppDelegateInstance.remoteDict hasObjectForKey:@"news_id"]) {
        NSString *Id = [AppDelegateInstance.remoteDict safeStringForKey:@"news_id"];
        WebViewController *vc = [[WebViewController alloc]init];
        vc.url = [NSString stringWithFormat:@"%@%@%@",base_url,@"wap/news_detail.html?new_id=",Id];;
        [self.navigationController pushViewController:vc animated:YES];
        AppDelegateInstance.remoteDict = nil;
    }
}

-(void)showAdUrl
{
    if (AppDelegateInstance.adUrl!=nil) {
        WebViewController *vc = [[WebViewController alloc]init];
        vc.url = AppDelegateInstance.adUrl;
        [self.navigationController pushViewController:vc animated:YES];
        AppDelegateInstance.adUrl = nil;
    }
}

- (void)releaseTimer
{
    if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
    }
}

- (IBAction)showGuide1:(UIButton *)sender {
    [self.guide0 removeFromSuperview];
    [AppDelegateInstance.window addSubview:self.guide1];
}
- (IBAction)showGuide2:(UIButton *)sender {
    [self.guide1 removeFromSuperview];
    [AppDelegateInstance.window addSubview:self.guide2];
}

- (IBAction)removeGuide2:(UIButton *)sender {
    [self.guide2 removeFromSuperview];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.listData.count == 0) {
        [self getChannelList];
        return;
    }
}

- (void)themeColorChange
{
    [super themeColorChange];
    if ([ThemeManager instance].isDarkTheme) {
        self.timeLabel.textColor = TextColor1Light;
        self.timeLabel.backgroundColor = LightBackgroundColor;
        self.videoBtn.selected = YES;
        self.playViewBg = @[@"playView_light1",@"playView_light2"];
    }
    else{
        self.videoBtn.selected = NO;
        self.timeLabel.textColor = TextColor1;
        self.timeLabel.backgroundColor = DayBackgroundColor;
        self.playViewBg = @[@"playView_day1",@"playView_day2"];
    }
    [self changePlayBg];
}

- (void)themeFontChange
{
    self.timeLabel.font = defaultSizeFont(17);
}

- (void)search
{
    SearchViewController *vc = [[SearchViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupChannelView{
    self.channelView = [[NewsTabView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    [self.view addSubview:self.channelView];
    __weak NewsViewController *weakSelf = self;
    self.channelView.selectIndexPath = ^(NSIndexPath *indexPath) {
        NSDictionary *channel = [weakSelf.like objectAtIndex:indexPath.item];
        NSString *string = [channel safeStringForKey:@"channel_id"];
        NSArray *array = [weakSelf.listData objectForKey:string];
        if (array.count == 0) {
            [weakSelf getNewsList:channel];
        }
        [weakSelf.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    };
    self.channelView.addMethod = ^{
        ChannelViewController *vc = [[ChannelViewController alloc]init];
        vc.like = weakSelf.like;
        vc.dislike = weakSelf.dislike;
        vc.sortFinish = ^(NSArray *like, NSArray *dislike) {
            AppDelegateInstance.likeList = [like mutableCopy];
            [AppDelegateInstance.likeList writeToFile:[AppDelegateInstance returnLikeFilePath] atomically:YES];
            [weakSelf setChannelWith:like dislike:dislike];
        };
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [weakSelf presentViewController:nvc animated:YES completion:nil];
    };
}

- (void)setupCollectionView
{
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(ScreenWidth, ScreenHeight-statusHeight-navHeight-tabBarHeight-self.channelView.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.channelView.bottom, ScreenWidth, ScreenHeight-statusHeight-navHeight-tabBarHeight-self.channelView.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [ThemeManager instance].isDarkTheme ? LightBackgroundColor : DayBackgroundColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:[TableCell class] forCellWithReuseIdentifier:@"TableCell"];
    [self.view addSubview:self.collectionView];
}

- (void)getChannelList
{
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=channel" params:nil block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            [self.listData removeAllObjects];
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSDictionary *recommend = @{@"channel_id":@"0",@"channel_content":@"推荐"};
            NSMutableArray *like = [NSMutableArray arrayWithArray:[dict safeArrayForKey:@"like"]];
            [like insertObject:recommend atIndex:0];
            NSArray *dislike = [dict safeArrayForKey:@"dislike"];
            [self setChannelWith:like dislike:dislike];
            
            [self.pageForChannelImageAd removeAllObjects];
            [self.pageForChannelTextAd removeAllObjects];
            for (NSDictionary *c in [dict safeArrayForKey:@"dislike"]) {
                [self.pageForChannelImageAd setValue:@(0) forKey:[c safeStringForKey:@"channel_id"]];
                [self.pageForChannelTextAd setValue:@(0) forKey:[c safeStringForKey:@"channel_id"]];
            }
            for (NSDictionary *c in [dict safeArrayForKey:@"like"]) {
                [self.pageForChannelImageAd setValue:@(0) forKey:[c safeStringForKey:@"channel_id"]];
                [self.pageForChannelTextAd setValue:@(0) forKey:[c safeStringForKey:@"channel_id"]];
            }
        }
        else{
            [self getChannelList];
        }
    }];
}

- (void)setChannelWith:(NSArray*)like dislike:(NSArray*)dislike
{
    if (AppDelegateInstance.likeList.count==0||AppDelegateInstance.likeList.count!=like.count) {
        AppDelegateInstance.likeList = [like mutableCopy];
        [AppDelegateInstance.likeList writeToFile:[AppDelegateInstance returnLikeFilePath] atomically:YES];
    }
    self.like = AppDelegateInstance.likeList;
//    self.like = like;
    self.dislike = dislike;
    self.listenManager.likeList = AppDelegateInstance.likeList;
//    self.listenManager.likeList = like;
    for (NSDictionary *channel in self.like) {
        NSMutableArray *array = [self.listData objectForKey:[channel safeStringForKey:@"channel_id"]];
        if (!array) {
            array = [[NSMutableArray alloc]init];
            [self.listData setObject:array forKey:[channel safeStringForKey:@"channel_id"]];
        }
    }
    [self.collectionView reloadData];
    self.channelList = [Channel mj_objectArrayWithKeyValuesArray:self.like];
    self.channelView.data = self.channelList;
    if (self.like.count > 0) {
        NSDictionary *channel = [self.like firstObject];
        NSMutableArray *array = [self.listData objectForKey:[channel safeStringForKey:@"channel_id"]];
//        if (array.count == 0) {
//            [self getNewsList:[self.like firstObject]];
//        }
    }
}

- (void)getNewsList:(NSDictionary*)channel
{
    self.nowChannel = channel;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [self getTextAd:NO];
    });
    dispatch_group_async(group, queue, ^{
        [self getAd:NO];
    });
         dispatch_group_notify(group, queue, ^{
             dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSInteger refreshtime = 0;
    NSNumber *channel_id = [channel safeNumberForKey:@"channel_id"];
    NSDictionary *params = @{@"channel_id":channel_id,@"time":@(refreshtime)};
    [HTTPClientInstance postMethod:@"act=news" params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            for (Channel *nel in self.channelList) {
                if (nel.channel_id == [channel_id intValue]) {
                    nel.hasUpdate = NO;
                    [self.channelView reloadData];
                    break;
                }
            }
            NSString * channelid = [channel safeStringForKey:@"channel_id"];
            NSMutableArray *array = [self.listData objectForKey:channelid];
            if (!array) {
                array = [[NSMutableArray alloc]init];
                [self.listData setObject:array forKey:channelid];
            }
            [array removeAllObjects];
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSArray *news = [dict safeArrayForKey:@"news"];
            NSArray *newsArr = [NewsObject mj_objectArrayWithKeyValuesArray:news];
            if (newsArr.count < 15) {
                [self.showData setObject:@YES forKey:channelid];
            }
            else{
                [self.showData setObject:@NO forKey:channelid];
            }
            [array addObjectsFromArray:newsArr];
            [self loadDataSuccess];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
             
                      });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.like.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TableCell" forIndexPath:indexPath];
    if (!cell.tableCellDelegate) {
        cell.tableCellDelegate = self;
    }
    NSDictionary *channel = [self.like objectAtIndex:indexPath.item];
    NSString *string = [channel safeStringForKey:@"channel_id"];
    BOOL showdata = [[self.showData objectForKey:string] boolValue];
    NSArray *array = [self.listData objectForKey:string];
    NSDictionary *dictionary = [self.dataDic objectForKey:string];
    cell.channel = channel;
    cell.showEnd = showdata;
    cell.data = dictionary;
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/ScreenWidth;
    self.channelView.selectIndex = page;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0];
    TableCell *cell = (TableCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSString *string = [cell.channel safeStringForKey:@"channel_id"];
    NSMutableArray *array = [self.listData objectForKey:string];
    if (array.count == 0) {
        [cell.tableCellDelegate tableCell:cell loadNewsListData:0 block:^{
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)comment:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    CommentViewController *vc = [[CommentViewController alloc]init];
    vc.news_id = news.news_id;
    vc.view.frame = ScreenBounds;
    [AppDelegateInstance.window.rootViewController addChildViewController:vc];
    [AppDelegateInstance.window.rootViewController.view addSubview:vc.view];
}
- (void)collect:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    NewsCell *cell = [userInfo safeObjectForKey:@"cell"];
    [SVProgressHUD show];
    NSDictionary *dict = @{@"new_id":news.news_id,@"type":@"add"};
    [HTTPClientInstance postMethod:@"act=newsuser&op=colloctNews" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            news.collected = !news.collected;
            if (news.collected) {
                [MobClick event:@"collect" label:[NSString stringWithFormat:@"%@",news.news_id]];
                [AlertHelper showAlertWithTitle:@"已收藏"];
            }
            else{
                [AlertHelper showAlertWithTitle:@"已取消收藏"];
            }
            cell.news = news;
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)share:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    ShareView *view = [[NSBundle mainBundle]loadNibNamed:@"ShareView" owner:self options:nil][0];
    view.shareType = @"newsShare";
    view.frame = ScreenBounds;
    view.shareUrl = [NSString stringWithFormat:@"%@%@%@",base_url,@"wap/news_detail.html?new_id=",news.news_id];
    view.shareTitle = news.news_title;
    view.shareContent = news.news_content;
    if (news.news_pic.length > 0) {
        view.images = news.news_pic;
    }
    [AppDelegateInstance.window addSubview:view];
}
- (void)like:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    NewsCell *cell = [userInfo safeObjectForKey:@"cell"];
    [SVProgressHUD show];
    [HTTPClientInstance postMethod:@"act=newsuser&op=likeNews" params:@{@"new_id":news.news_id,@"type":@"add"} block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        [SVProgressHUD dismiss];
        if (code == 200) {
            news.likenew = !news.likenew;
            cell.news = news;
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
}

- (void)report:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    FeedBackViewController *vc = [[FeedBackViewController alloc]init];
    vc.news_id = news.news_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reward:(NSNotification*)notification
{/*
    NSDictionary *userInfo = notification.userInfo;
    NewsObject *news = [userInfo safeObjectForKey:@"data"];
    self.rewardNews = news;
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"打赏金额" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"打赏1元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        productId = @"1yuan";
        self.rewardPrice = @1;
        [self requestProductData:productId];
    }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"打赏3元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        productId = @"3yuan";
        self.rewardPrice = @3;
        [self requestProductData:productId];
    }];
    UIAlertAction *ac3 = [UIAlertAction actionWithTitle:@"打赏8元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        productId = @"8yuan";
        self.rewardPrice = @8;
        [self requestProductData:productId];
    }];
    UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [vc addAction:ac1];
    [vc addAction:ac2];
    [vc addAction:ac3];
    [vc addAction:ac0];
    [self presentViewController:vc animated:YES completion:nil];*/
}

- (void)tableCell:(TableCell *)cell loadNewsListData:(NSInteger)time block:(void (^)(void))block
{
    NSInteger refreshtime = time == 0 ? 0 : time;
    self.nowChannel = cell.channel;
        NSNumber *channel_id = [cell.channel safeNumberForKey:@"channel_id"];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
    
            dispatch_group_async(group, queue, ^{
    if (time==0) {
        [(NSMutableArray*)[self.textAdData objectForKey:channel_id] removeAllObjects];
        [self.pageForChannelTextAd setValue:@(0) forKey:[NSString stringWithFormat:@"%@",channel_id]];
        [self getTextAd:NO];
    }         else
    {
        dispatch_semaphore_signal(semaphore);
    }
            });
        dispatch_group_async(group, queue, ^{
                if (time==0) {
                    [(NSMutableArray*)[self.imageAdData objectForKey:channel_id] removeAllObjects];
                    [self.pageForChannelImageAd setValue:@(0) forKey:[NSString stringWithFormat:@"%@",channel_id]];
                    [self getAd:NO];
                }
            else
            {
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_group_notify(group, queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDictionary *params = @{@"channel_id":channel_id,@"time":@(refreshtime)};
    [HTTPClientInstance postMethod:@"act=news" params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (block) {
            block();
        }
        if (code == 200) {
            NSString *string = [cell.channel safeStringForKey:@"channel_id"];
            NSMutableArray *array = [self.listData objectForKey:string];
            if (!array) {
                array = [[NSMutableArray alloc]init];
                [self.listData setObject:array forKey:string];
            }
            if (time == 0) {
                [array removeAllObjects];
                for (Channel *nel in self.channelList) {
                    if (nel.channel_id == [channel_id intValue]) {
                        nel.hasUpdate = NO;
                        [self.channelView reloadData];
                        break;
                    }
                }
            }
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            NSArray *news = [dict safeArrayForKey:@"news"];
            NSArray *newsArr = [NewsObject mj_objectArrayWithKeyValuesArray:news];
            if (newsArr.count < 15) {
                [self.showData setObject:@YES forKey:string];
            }
            else{
                [self.showData setObject:@NO forKey:string];
            }
            [array addObjectsFromArray:newsArr];
            [self loadDataSuccess];
        }
        else{
            [AlertHelper showAlertWithDict:data];
        }
    }];
                 });
}

- (void)timerForRedPoint
{
    NSString *lastUpdata = [[NSUserDefaults standardUserDefaults]objectForKey:@"kLastUpdataRedPoint"];
    NSDictionary *lastUpdataDict = [Tool stringToJson:lastUpdata];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if (self.listData.count == 0) {
        return;
    }
    for (NSString *key in self.listData) {
        NSArray *array = self.listData[key];
        NSNumber *time = @0;
        if (array.count > 0) {
            for (int i=0; i<array.count; i++) {
                if ([array[i] isKindOfClass:[NewsObject class]]) {
                    NewsObject *object = array[i];
                    if ([time doubleValue]<[object.news_showtime doubleValue]) {
                        time = object.news_showtime;
                    }
                }
                if (i == 1) {
                    break;
                }
            }
        }
        if ([lastUpdataDict hasObjectForKey:key]) {
            if ([time doubleValue]<[lastUpdataDict safeLongLongForKey:key]) {
                time = [lastUpdataDict safeNumberForKey:key];
            }
        }
        [dict setObject:time forKey:key];
    }
    NSString *channelString = [Tool jsonToString:dict];
    NSDictionary *params = @{@"channel_string":channelString};
    [HTTPClientInstance postMethod:@"act=news&op=checkNews1" params:params block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            [[NSUserDefaults standardUserDefaults]setObject:channelString forKey:@"kLastUpdataRedPoint"];
            NSInteger unreadMessage = 0;
            NSString *channel_now = [self.nowChannel safeStringForKey:@"channel_id"];
            NSDictionary *dict = [data safeDictionaryForKey:@"datas"];
            for (Channel *channel in self.channelList) {
                NSNumber *object = [dict safeObjectForKey:[NSString stringWithFormat:@"%d",channel.channel_id]];
                channel.hasUpdate = [object boolValue];
                NSString *channelID = [NSString stringWithFormat:@"%d",channel.channel_id];
                if ([channelID isEqualToString:channel_now]) {
                    unreadMessage = [object integerValue];
                }
            }
            [self setUnreadMsgCount:unreadMessage];
            [self.channelView reloadData];
        }
        else{
        }
    }];
}

#pragma mark - 阅读
- (IBAction)stopVideo:(UIButton *)sender {
    [self.listenManager stop];
    AppDelegateInstance.isReadingNews = NO;
    self.playBtn.selected = NO;
    self.playStatus = NO;
    [self changePlayBg];
}
- (IBAction)showPlayView:(UIButton *)sender {
    self.playStatus = YES;
    [self playVideo:self.playBtn];
    [MobClick event:@"listenNews"];
}

- (void)setPlayStatus:(BOOL)playStatus
{
    _playStatus = playStatus;
    self.playView.hidden = !playStatus;
}

- (IBAction)playVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    BOOL canplay = sender.selected;
    if (canplay) {
//        TableCell *tableCell = [self.collectionView.visibleCells firstObject];
//        NewsObject *object = nil;
//        for (UITableViewCell *cell in tableCell.tableView.visibleCells) {
//            if ([cell isKindOfClass:[NewsCell class]]) {
//                NewsCell *newsCell = (NewsCell*)cell;
//                NewsObject *obj = newsCell.news;
//                if ([obj.news_createtime doubleValue]>[object.news_createtime doubleValue]) {
//                    object = obj;
//                    if (!obj.news_top) {
//                        break;
//                    }
//                }
//            }
//        }
//        if (object) {
//            if ([Tool isTodayTime:[object.news_showtime doubleValue]]) {

                NSString * channelid = [self.nowChannel safeStringForKey:@"channel_id"];
                NSMutableArray *array = [self.listData objectForKey:channelid];
                [self.listenManager setCurrentChannel:channelid listenList:array topNewsTime:0];
//            }
//            else{
//                [AlertHelper showAlertWithTitle:@"新闻过期"];
//                self.playBtn.selected = NO;
//            }
//        }
//        else{
//            self.playBtn.selected = NO;
//            [AlertHelper showAlertWithTitle:@"新闻加载中"];
//        }
    }
    else{
        AppDelegateInstance.isReadingNews = NO;
        [self.listenManager pause];
    }
    [self changePlayBg];
}

- (void)changePlayBg
{
    if (self.playBtn.selected) {
        self.playBgView.image = [UIImage imageNamed:self.playViewBg[1]];
    }
    else{
        self.playBgView.image = [UIImage imageNamed:self.playViewBg[0]];
    }
}

#pragma mark - 广告
- (void)getAd:(BOOL)more
{
    if (!self.nowChannel) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@1 forKey:@"type"];
    [dict setValue:[LocationService sharedInstance].lastCity forKey:@"areaname"];
    NSNumber *channel_id = [self.nowChannel safeNumberForKey:@"channel_id"];
    [dict setValue:channel_id forKey:@"channelid"];
    [dict setValue:[self.pageForChannelImageAd valueForKey:[NSString stringWithFormat:@"%@",channel_id]] forKey:@"page"];
    [HTTPClientInstance postMethod:@"act=advertise&op=getAd" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (array.count > 0) {
//                NSDictionary *dict = [array firstObject];
//                Ad *ad = [Ad mj_objectWithKeyValues:dict];
                if([self.imageAdData objectForKey:channel_id]==nil)
                {
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    [self.imageAdData setObject:tempArray forKey:channel_id];
                }
                for (NSDictionary *dict in array) {
                    Ad *ad = [Ad mj_objectWithKeyValues:dict];
                    [(NSMutableArray*)[self.imageAdData objectForKey:channel_id] addObject:ad];
                }
//                [self.imageAdData setObject:ad forKey:channel_id];
//                [self loadDataSuccess];
            }
            if (array.count==10) {
                [self.pageForChannelImageAd setValue:@((int)[self.pageForChannelImageAd valueForKey:[NSString stringWithFormat:@"%@",channel_id]]+1) forKey:[NSString stringWithFormat:@"%@",channel_id]];
                [self getAd:YES];
            }
        }
        else{
        }
        if (!more) {
             dispatch_semaphore_signal(semaphore);
        }
    }];
}

- (void)loadDataSuccess
{
    [self timerForRedPoint];
    if (!self.nowChannel) {
        return;
    }
    NSMutableArray *array = [self.listData objectForKey:[self.nowChannel safeStringForKey:@"channel_id"]];
    NSNumber *channel_id = [self.nowChannel safeNumberForKey:@"channel_id"];
//    Ad *textAd = [self.textAdData objectForKey:channel_id];
//    Ad *imageAd = [self.imageAdData objectForKey:channel_id];
    NSMutableArray *textAdArray = [self.textAdData objectForKey:channel_id];
    NSMutableArray *imageAdArray = [self.imageAdData objectForKey:channel_id];
    int textPage = 0;
    for (NewsObject *object in array) {
        if (textAdArray.count>0) {
            if (textPage==textAdArray.count) {
                textPage=0;
            }
            object.textAD = [textAdArray objectAtIndex:textPage++];
        }
//        else{
//            [self getTextAd];
//            break;
//        }
    }
    if (imageAdArray.count>0) {
        int imagePage = 0;
        for (int i = 0; i < array.count; i++) {
            NewsObject *object = array[i];
            if (imagePage==imageAdArray.count) {
                imagePage = 0;
            }
            if (i == 4) {
                object.ad = [imageAdArray objectAtIndex:imagePage];
                imagePage ++;
            }
            else if (i == 14){
                object.ad = [imageAdArray objectAtIndex:imagePage];
                imagePage ++;
            }
            else if ( (i-15) % 20 == 19){
                object.ad = [imageAdArray objectAtIndex:imagePage];
                imagePage ++;
            }
            else{
                object.ad = nil;
            }
        }
    }
    else{
//        [self getAd];
    }
    [self sortList];
}

- (void)sortList
{
    NSString *channel_id = [self.nowChannel safeStringForKey:@"channel_id"];
    NSMutableArray *array = [self.listData objectForKey:channel_id];
    NSMutableDictionary *dict = [self.dataDic objectForKey:channel_id];
    if (!dict) {
        dict = [[NSMutableDictionary alloc]init];
        NSMutableArray *keys = [[NSMutableArray alloc]init];
        [dict setObject:keys forKey:@"keys"];
        NSMutableDictionary *channel_data = [[NSMutableDictionary alloc]init];
        [dict setObject:channel_data forKey:@"channel_data"];
        [self.dataDic setObject:dict forKey:channel_id];
    }
    NSMutableArray *keys = [dict objectForKey:@"keys"];
    NSMutableDictionary *channel_data = [dict objectForKey:@"channel_data"];
    [keys removeAllObjects];
    [channel_data removeAllObjects];
    BOOL same = NO;
    if (array.count > 1) {
        NewsObject *obj1 = array[0];
        NewsObject *obj2 = array[1];
        same = [obj1.news_date isEqualToString:obj2.news_date];
    }
    for (NewsObject *object in array) {
        NSString *key = object.news_date;
        if (object.news_top && !same) {
            key = @"top";
        }
        NSMutableArray *list = [channel_data objectForKey:key];
        if (!list) {
            list = [[NSMutableArray alloc]init];
            [keys addObject:key];
            [channel_data setObject:list forKey:key];
        }
        [list addObject:object];
    }
    [self.collectionView reloadData];
}

- (void)getVioceAd
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@4 forKey:@"type"];
    [dict setValue:[LocationService sharedInstance].lastCity forKey:@"areaname"];
    NSNumber *channel_id = [self.nowChannel safeNumberForKey:@"channel_id"];
    [dict setValue:channel_id forKey:@"channelid"];
    [HTTPClientInstance postMethod:@"act=advertise&op=getAd" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (array.count > 0) {
                NSDictionary *dict = [array firstObject];
                NSString *videoUrl = [dict safeStringForKey:@"info_url"];
                self.listenManager.videoUrl = videoUrl;
            }
        }
        else{
        }
    }];
}

- (void)getTextAd:(BOOL)more
{
    if (!self.nowChannel) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@2 forKey:@"type"];
    [dict setValue:[LocationService sharedInstance].lastCity forKey:@"areaname"];
    NSNumber *channel_id = [self.nowChannel safeNumberForKey:@"channel_id"];
    [dict setValue:channel_id forKey:@"channelid"];
    [dict setValue:[self.pageForChannelTextAd valueForKey:[NSString stringWithFormat:@"%@",channel_id]] forKey:@"page"];
    [HTTPClientInstance postMethod:@"act=advertise&op=getAd" params:dict block:^(NSDictionary *data, NSString *error, int code, NSError *requestFailed) {
        if (code == 200) {
            NSArray *array = [data safeArrayForKey:@"datas"];
            if (array.count > 0) {
//                NSDictionary *dict = [array firstObject];
//                Ad *ad = [Ad mj_objectWithKeyValues:dict];
//                [self.textAdData setObject:ad forKey:channel_id];
//                [self loadDataSuccess];
                if([self.textAdData objectForKey:channel_id]==nil)
                {
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    [self.textAdData setObject:tempArray forKey:channel_id];
                }
                for (NSDictionary *dict in array) {
                    Ad *ad = [Ad mj_objectWithKeyValues:dict];
                    [(NSMutableArray*)[self.textAdData objectForKey:channel_id] addObject:ad];
                }
            }
            if (array.count==10) {
                [self.pageForChannelTextAd setValue:@((int)[self.pageForChannelTextAd valueForKey:[NSString stringWithFormat:@"%@",channel_id]]+1) forKey:[NSString stringWithFormat:@"%@",channel_id]];
                [self getTextAd:YES];
            }
        }
        else{
        }
        if (!more) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
}

-(void)setUnreadMsgCount:(NSInteger)unreadMessageCount
{
    return;
    UITabBarController *tabVc = AppDelegateInstance.window.rootViewController;
    UINavigationController *navc = tabVc.childViewControllers[0];
    if (unreadMessageCount==0) {
        navc.tabBarItem.badgeValue = nil;
    }
    else{
        navc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadMessageCount];
    }
}

@end

