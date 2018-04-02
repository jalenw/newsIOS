//
//  NewsTabView.m
//  News
//
//  Created by intexh on 2017/10/30.
//  Copyright © 2017年 YJW. All rights reserved.
//

#import "NewsTabView.h"
#import "Channel.h"

@interface TabCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
@property (nonatomic) BOOL hightLight;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *redPoint;

@end

@implementation TabCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc]initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleCenter | UIViewAutoresizingFlexibleSize;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        CGFloat redPointWidth = 6;
        self.redPoint = [[UIView alloc]initWithFrame:CGRectMake(self.width - redPointWidth, 8, redPointWidth, redPointWidth)];
        self.redPoint.layer.masksToBounds = YES;
        self.redPoint.layer.cornerRadius = self.redPoint.width/2.0;
        self.redPoint.backgroundColor = [UIColor redColor];
        self.redPoint.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.redPoint];
        [self themeColorChange];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
        self.redView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-1, 0, 1)];
        self.redView.backgroundColor = ThemeColor;
        [self addSubview:self.redView];
    }
    return self;
}

- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme) {
        self.label.textColor = TextColor1Light;
        self.backgroundColor = RGB(42, 41, 47);
    }
    else{
        self.label.textColor = TextColor1;
        self.backgroundColor = [UIColor whiteColor];
    }
    if (self.hightLight) {
        self.label.textColor = ThemeColor;
    }
}

- (void)setHightLight:(BOOL)hightLight
{
    _hightLight = hightLight;
    [self themeColorChange];
    
    CGFloat font = [ThemeManager instance].textFont*2+17;
    NSString *string = self.label.text;
    self.redView.width = font*string.length;
    CGSize size = [Tool sizeWithFont:defaultSizeFont(17) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) string:string];
    size.width += 15;
    self.redView.centerX = size.width/2.0;
    self.redView.hidden = !hightLight;
}

@end

@interface NewsTabView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end

@implementation NewsTabView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    CGFloat buttonWidth = 48;
    self.addButton = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - buttonWidth, 0, buttonWidth, self.height)];
    [self.addButton addTarget:self action:@selector(addAct) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(10, 10);
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - buttonWidth, self.height) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[TabCell class] forCellWithReuseIdentifier:@"TabCell"];
    [self addSubview:self.collectionView];
    [self themeColorChange];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeFontChange) name:kNotificationModelFontChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeColorChange) name:kNotificationModelColorChange object:nil];
    self.redView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-1, 0, 1)];
    self.redView.backgroundColor = ThemeColor;
}

- (void)setData:(NSArray *)data
{
    _data = data;
    [self.collectionView reloadData];
    if (data.count > 0) {
        self.lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        self.selectIndexPath(self.lastIndexPath);
    }
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)themeFontChange
{
    [self.collectionView reloadData];
}
- (void)themeColorChange
{
    if ([ThemeManager instance].isDarkTheme) {
        [self.addButton setImage:[UIImage imageNamed:@"light_add"] forState:UIControlStateNormal];
        self.backgroundColor = RGB(42, 41, 47);
        self.collectionView.backgroundColor = RGB(42, 41, 47);
    }
    else{
        [self.addButton setImage:[UIImage imageNamed:@"day_add"] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor whiteColor];
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }
}
- (void)addAct{
    self.addMethod();
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TabCell" forIndexPath:indexPath];
    //NSDictionary *dict = [self.data objectAtIndex:indexPath.item];
    Channel *channel = [self.data objectAtIndex:indexPath.item];
    NSString *string = channel.channel_content;//[dict safeStringForKey:@"channel_content"];
    cell.redPoint.hidden = !channel.hasUpdate;
    cell.label.font = defaultSizeFont(17);
    cell.label.text = string;
    if (indexPath == self.lastIndexPath) {
        cell.hightLight = YES;
    }
    else{
        cell.hightLight = NO;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSDictionary *dict = [self.data objectAtIndex:indexPath.item];
    Channel *channel = [self.data objectAtIndex:indexPath.item];
    NSString *string = channel.channel_content;//[dict safeStringForKey:@"channel_content"];
    CGSize size = [Tool sizeWithFont:defaultSizeFont(17) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) string:string];
    size.height = self.height;
    size.width += 15;
    return size;
}

- (void)setSelectIndex:(int)selectIndex
{
    _selectIndex = selectIndex;
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectIndex inSection:0];
    [self changeIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath(indexPath);
    [self changeIndexPath:indexPath];
}

- (void)changeIndexPath:(NSIndexPath*)indexPath
{
    self.lastIndexPath = indexPath;
    Channel *channel = self.data[indexPath.item];
    [MobClick event:@"channel" label:channel.channel_content];
    [self.collectionView reloadData];
}

@end
