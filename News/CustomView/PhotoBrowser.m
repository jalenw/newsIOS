//
//  YYPhotoBrowserVC.m
//  Test
//
//  Created by xqj on 13-6-9.
//  Copyright (c) 2013年 syezon. All rights reserved.
//

#import "PhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "AlertHelper.h"
#import "UIView+RSAdditions.h"

static BOOL IsShowingPhotoBrowser;

@interface PhotoBrowser ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
{
    UIScrollView *_scrollView;
    
    NSArray *_smallImageInfos;
    NSArray *_bigImageInfos;
    NSMutableArray *_imageViewArr;             //UIImageView数组
    NSMutableArray *_scrollViewArr;
    NSMutableArray *_progressViewArr;
    NSInteger _currentIndex;            //当前图片序号
    CGFloat _offset;
    
    BOOL _showingLongPressMenu;
    
    UIPageControl *_pageControl;
}

@end

@implementation PhotoBrowser

- (id)initWithBigImageInfos:(NSArray *)bigImageInfos                    //url or image
            smallImageInfos:(NSArray *)smallImageInfos
                 imageIndex:(NSInteger)imageIndex
                   delegate:(id<PhotoBrowserDelegate>)delegate
{
    self = [self initWithFrame:ScreenBounds];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.delegate = delegate;
        _currentIndex = imageIndex;
        _bigImageInfos = bigImageInfos;
        _smallImageInfos = smallImageInfos;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:ScreenBounds];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setDelegate:self];
        [_scrollView setContentSize:CGSizeMake(ScreenWidth * [_bigImageInfos count], ScreenHeight)];
        [_scrollView setContentOffset:CGPointMake(ScreenWidth * _currentIndex, 0)];
        [self addSubview:_scrollView];
        
        [self initImageViews];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height - 37, self.width, 37)];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        _pageControl.numberOfPages = _bigImageInfos.count;
        _pageControl.currentPage = _currentIndex;
        [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
    }
    
    return self;
}

- (void)show
{
    IsShowingPhotoBrowser = YES;
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow endEditing:YES];
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];

    UIImageView* imageView = nil;
    UIImageView* originImageView = nil;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:animationImageViewAtIndex:)])
    {
        originImageView = [self.delegate photoBrowser:self animationImageViewAtIndex:_currentIndex];
        if ([originImageView respondsToSelector:@selector(image)] && originImageView.image)
        {
            imageView = [[UIImageView alloc] initWithImage:originImageView.image];
            imageView.clipsToBounds = YES;
            imageView.contentMode = originImageView.contentMode;
            [keyWindow addSubview:imageView];

            CGRect startRect = [originImageView convertRect:originImageView.bounds toView:keyWindow];
            imageView.frame = startRect;
            _scrollView.alpha = 0;
        }
    }
    
    self.alpha = 0;
    keyWindow.userInteractionEnabled = NO;
    
    UIImageView* scrollImageView = [_imageViewArr objectAtIndex:_currentIndex];
    if (originImageView)
    {
        originImageView.hidden = YES;
        if (scrollImageView.width == 0 && originImageView.image)
        {
            CGFloat imageHeight = ScreenWidth * originImageView.image.size.height / originImageView.image.size.width;
            scrollImageView.frame = CGRectMake(0, (ScreenHeight - imageHeight) / 2, ScreenWidth, imageHeight);
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        imageView.frame = [scrollImageView convertRect:scrollImageView.bounds toView:keyWindow];
    } completion:^(BOOL finished) {
        _scrollView.alpha = 1;
        keyWindow.userInteractionEnabled = YES;
        [imageView removeFromSuperview];
        if (originImageView)
        {
            originImageView.hidden = NO;
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }];
}

- (void)hide
{
    IsShowingPhotoBrowser = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIImageView* imageView = nil;
    UIImageView* originImageView = nil;
    CGRect targetRect = CGRectZero;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:animationImageViewAtIndex:)])
    {
        originImageView = [self.delegate photoBrowser:self animationImageViewAtIndex:_currentIndex];
        if ([originImageView respondsToSelector:@selector(image)] && originImageView.image)
        {
            targetRect = [originImageView convertRect:originImageView.bounds toView:keyWindow];
            imageView = [[UIImageView alloc] initWithImage:originImageView.image];
            imageView.clipsToBounds = YES;
            imageView.contentMode = originImageView.contentMode;
            [keyWindow addSubview:imageView];
            
            _scrollView.alpha = 0;
        }
    }
    
    if (imageView)
    {
        UIImageView* scrollImageView = [_imageViewArr objectAtIndex:_currentIndex];
        imageView.frame = [scrollImageView convertRect:scrollImageView.bounds toView:keyWindow];
        [keyWindow addSubview:imageView];
    }
    if (originImageView)
    {
        originImageView.hidden = YES;
    }
    keyWindow.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.3 animations:^{

        self.alpha = 0;
        if (imageView)
        {
            imageView.frame = targetRect;
        }
    } completion:^(BOOL finished) {
        keyWindow.userInteractionEnabled = YES;

        if (imageView)
        {
            [imageView removeFromSuperview];
        }
        if (originImageView)
        {
            originImageView.hidden = NO;
        }
        
        [self removeFromSuperview];
    }];
}

- (void)setImageIndex:(NSInteger)imageIndex
{
    _currentIndex = imageIndex;
    [_scrollView setContentOffset:CGPointMake(_currentIndex * _scrollView.width, 0)];
    _pageControl.currentPage = _currentIndex;
}

- (void)updateImageViewForIndex:(NSInteger)index image:(UIImage *)image
{
    UIScrollView* scrollView = [_scrollViewArr objectAtIndex:index];
    
    UIImageView *imageView = [_imageViewArr objectAtIndex:index];
    [imageView setImage:image];
    
    CGFloat height = image.size.height * ScreenWidth / image.size.width;
    imageView.frame = CGRectMake(0, 0, ScreenWidth, height);
    if (imageView.height < scrollView.height)
    {
        imageView.top = (scrollView.height - imageView.height) / 2;
    }
    
    scrollView.contentSize = CGSizeMake(imageView.size.width, MAX(imageView.size.height, scrollView.height));
}

- (void)downloadContentWithIndex:(NSInteger)index
{
    NSString *urlStr = [_bigImageInfos objectAtIndex:index];
    if (![urlStr isKindOfClass:[NSString class]])
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if(!image)
    {
        UIImageView* progressView = [_progressViewArr objectAtIndex:index];
        progressView.hidden = NO;
        progressView.width = ScreenWidth * 0.01;
        [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                   options:SDWebImageLowPriority
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
         {
             CGFloat progress = (expectedSize > 0) ? (receivedSize / (float)expectedSize) : 0.01;
             progressView.width = progress * ScreenWidth;
         }
                                                 completed:^(UIImage * _Nullable aImage, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
         {
             if (finished && aImage)
             {
                 [self updateImageViewForIndex:index image:aImage];
                 progressView.width = ScreenWidth;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      progressView.hidden = YES;
                 });
             }
             else
             {
                 progressView.hidden = YES;
             }
         }];
    }
}

- (void)initImageViews
{
    _imageViewArr = [NSMutableArray array];
    _scrollViewArr = [NSMutableArray array];
    _progressViewArr = [NSMutableArray array];
    
    //增加手势识别
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 1;
//    [singleFingerOne setDelegate:self];
    [self addGestureRecognizer:singleFingerOne];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleFingerEvent:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
//    [doubleTap setDelegate:self];
    [self addGestureRecognizer:doubleTap];
    [singleFingerOne requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
//    [longPressGes setDelegate:self];
    [self addGestureRecognizer:longPressGes];
    
    for (int i = 0; i < _bigImageInfos.count; i++)
    {
        [self initImageView:i];
    }
    
    [self loadImageView:_currentIndex];
    for (NSInteger i = 0; i <= MAX((int)[_bigImageInfos count] - 1 - _currentIndex, _currentIndex); i++)
    {
        [self loadImageView:_currentIndex - i];
        [self loadImageView:_currentIndex + i];
    }
}

- (void)initImageView:(int)i
{
    if (i < 0 || i >= [_bigImageInfos count])
    {
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setTag:i+1];
    [imageView setUserInteractionEnabled:YES];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIScrollView *imageScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(ScreenWidth*i, 0, ScreenWidth, ScreenHeight)];
    imageScrollView.scrollsToTop = NO;
    imageScrollView.backgroundColor=[UIColor clearColor];
    imageScrollView.contentSize=imageView.frame.size;
    imageScrollView.maximumZoomScale=3.0;
    imageScrollView.minimumZoomScale=1;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    [imageScrollView setZoomScale:1.0];
    [imageScrollView addSubview:imageView];
    [imageScrollView setTag:i+1];
    imageScrollView.delegate = self;
    
    [_scrollView addSubview:imageScrollView];
    [_scrollViewArr addObject:imageScrollView];
    [_imageViewArr addObject:imageView];
    
    UIImageView* progressView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth * i, 0, ScreenWidth, 1)];
    progressView.backgroundColor = [UIColor grayColor];
    progressView.hidden = YES;
    [_progressViewArr addObject:progressView];
    [_scrollView addSubview:progressView];
}

- (void)loadImageView:(int)i
{
    if (i < 0 || i >= [_bigImageInfos count])
    {
        return;
    }
    
    NSObject *bigImageInfo = [_bigImageInfos objectAtIndex:i];
    UIImage *bigImage = [bigImageInfo isKindOfClass:[UIImage class]] ? (UIImage*)bigImageInfo : nil;
    if (!bigImage && [bigImageInfo isKindOfClass:[NSString class]])
    {
        bigImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:(NSString*)bigImageInfo];
    }
    
    if (bigImage)
    {
        [self updateImageViewForIndex:i image:bigImage];
    }
    else
    {
        NSObject* smallImageInfo = ([_smallImageInfos count] > i) ? [_smallImageInfos objectAtIndex:i] : nil;
        if (!smallImageInfo)
        {
            [self downloadContentWithIndex:i];
        }
        else if ([smallImageInfo isKindOfClass:[UIImage class]])
        {
            [self updateImageViewForIndex:i image:(UIImage*)smallImageInfo];
            [self downloadContentWithIndex:i];
        }
        else if ([smallImageInfo isKindOfClass:[NSString class]])
        {
            NSURL *url = [NSURL URLWithString:(NSString*)smallImageInfo];
            
            [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                       options:SDWebImageLowPriority
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
             {
             }
                                                      completed:^(UIImage * _Nullable aImage, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
             {
                 if (finished)
                 {
                     if (aImage)
                     {
                         [self updateImageViewForIndex:i image:aImage];
                     }

                     [self downloadContentWithIndex:i];
                 }
             }];
        }
    }
}

- (CGSize)fitScreenSize:(UIImage *)image
{
    if (!image) {
        return CGSizeZero;
    }

    CGSize origImgSize = [image size];
    origImgSize.width = MAX(origImgSize.width, 1);
    origImgSize.height = MAX(origImgSize.height, 1);
    float ratio = MIN(ScreenWidth / origImgSize.width, ScreenHeight / origImgSize.height);
    return CGSizeMake(origImgSize.width* ratio, origImgSize.height* ratio);
}

#pragma mark - event action

- (void)handleSingleFingerEvent:(UIGestureRecognizer *)gesture
{
    [self hide];
}

- (void)handleDoubleFingerEvent:(UIGestureRecognizer *)gesture
{
    UIScrollView *s = [_scrollViewArr objectAtIndex:_currentIndex];
    if (s.zoomScale<=1.0)
    {
        UIImageView* imageView = [_imageViewArr objectAtIndex:_currentIndex];
        CGPoint gesturePointInImageView = [imageView convertPoint:[gesture locationInView:gesture.view] fromView:gesture.view];
        CGRect zoomRect = [self zoomRectForScale:2.0 withCenter:gesturePointInImageView];
        [s zoomToRect:zoomRect animated:YES];
    }
    else
    {
        [s setZoomScale:1.0 animated:YES];
    }
}

- (void)longPressEvent:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
        [actionSheet showInView:self];
        
        UIImage *image=((UIImageView *)[_imageViewArr objectAtIndex:_currentIndex]).image;
        
        if (image.size.height<=150 && image.size.width<=150)
        {
            NSArray *array = actionSheet.subviews;
            for (int i=0; i<[array count]; i++)
            {
                if([array[i] isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=array[i];
                    if ([btn.titleLabel.text isEqualToString:@"保存到手机"]) {
                        btn.enabled=NO;
                    }
                }
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _showingLongPressMenu = NO;
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        NSString *urlStr=[_bigImageInfos objectAtIndex:_currentIndex];
        if ([urlStr isKindOfClass:[NSString class]]) {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
            if (image.size.width==0 && image.size.height==0) {
                image=((UIImageView *)[_imageViewArr objectAtIndex:_currentIndex]).image;
            }
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:),nil);
        }
        else if ([urlStr isKindOfClass:[UIImage class]])
        {
            UIImageWriteToSavedPhotosAlbum((UIImage*)urlStr, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:),nil);
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [SVProgressHUD showSuccessWithStatus:@"保存失败"];
        });
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.height / scale;
    zoomRect.size.width  = self.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [_imageViewArr objectAtIndex:_currentIndex];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView* imageView = [_imageViewArr objectAtIndex:_currentIndex];
    if (imageView.height < scrollView.height)
    {
        imageView.top = (scrollView.height - imageView.height) / 2;
    }
    else
    {
        imageView.top = 0;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    scrollView.contentSize = CGSizeMake(view.width, MAX(view.height, scrollView.height));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        NSInteger currentIndex = fabs(scrollView.contentOffset.x / self.frame.size.width);
        if (currentIndex == _currentIndex) { return; }

        _currentIndex = currentIndex;
        _pageControl.currentPage = _currentIndex;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didChangeToImageIndex:)])
        {
            [self.delegate photoBrowser:self didChangeToImageIndex:_currentIndex];
        }
        
        [self downloadContentWithIndex:currentIndex];
        
        CGPoint point;
        point=scrollView.contentOffset;
        point.x=currentIndex*self.width;
        scrollView.contentOffset=point;

        CGFloat x=scrollView.contentOffset.x;

        if (x!=_offset)
        {
            _offset=x;
        
            for (UIScrollView *s in scrollView.subviews)
            {
                if ([s isKindOfClass:[UIScrollView class]])
                {
                    [s setZoomScale:1.0 animated:NO];

                }
            }
        }
    }
}

- (void)changePage:(UIPageControl*)pageControl
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * pageControl.currentPage, 0) animated:YES];
}

+ (BOOL)isShowing
{
    return IsShowingPhotoBrowser;
}

@end
