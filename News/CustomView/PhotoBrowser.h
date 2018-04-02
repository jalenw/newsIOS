//
//  YYPhotoBrowserVC.h
//  Test
//
//  Created by xqj on 13-6-9.
//  Copyright (c) 2013年 syezon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
//#import "CommonBlockDefine.h"
@class PhotoBrowser;
@protocol PhotoBrowserDelegate <NSObject>

- (UIImageView*)photoBrowser:(PhotoBrowser*)browser animationImageViewAtIndex:(NSInteger)imageIndex;
@optional;
- (void)photoBrowser:(PhotoBrowser*)browser didChangeToImageIndex:(NSInteger)imageIndex;

@end

@interface PhotoBrowser : UIView

- (id)initWithBigImageInfos:(NSArray *)bigImageInfos                    //url or image
            smallImageInfos:(NSArray *)smallImageInfos
                 imageIndex:(NSInteger)imageIndex
                   delegate:(id<PhotoBrowserDelegate>)delegate;
- (void)show;
- (void)hide;
- (void)setImageIndex:(NSInteger)imageIndex;
+ (BOOL)isShowing;

@property (weak) id<PhotoBrowserDelegate> delegate;

@end
