//
//  PhotoPreviewCell.h
//  图片选择管理器
//
//  Created by Mac on 17/7/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWBAssetModel, ProgressView, PhotoPreviewView;
@interface PhotoPreviewCell : UICollectionViewCell
@property (nonatomic, strong)HWBAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
@property (nonatomic, strong) PhotoPreviewView *previewView;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
- (void)recoverSubviews;
@end



@interface PhotoPreviewView : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) ProgressView *progressView;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, strong) HWBAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
- (void)recoverSubviews;

@end