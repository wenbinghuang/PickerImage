//
//  PhotoPreviewCell.m
//  图片选择管理器
//
//  Created by Mac on 17/7/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PhotoPreviewCell.h"
#import "HWBAssetModel.h"
#import "ProgressView.h"
#import "HWBImageManager.h"
#import "HWBImageCropManager.h"

@implementation PhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.previewView = [[PhotoPreviewView alloc] initWithFrame:self.bounds];
        __weak typeof(self) weakSelf = self;
        [weakSelf.previewView setSingleTapGestureBlock:^{
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock();
            }
        }];
        
        [weakSelf setImageProgressUpdateBlock:^(double progress) {
            if (weakSelf.imageProgressUpdateBlock) {
                weakSelf.imageProgressUpdateBlock(progress);
            }
        }];
        [self addSubview:self.previewView];
    }
    return self;
}

- (void)setModel:(HWBAssetModel *)model {
    _model = model;
    self.previewView.asset = model.asset;
}

- (void)recoverSubviews {
    [self.previewView recoverSubviews];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _previewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

@end


@implementation PhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.0000 alpha:0.5000];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        
        [self configProgressView];
    }
    return self;
}


- (void)configProgressView {
    _progressView = [[ProgressView alloc] init];
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.frame.size.width - progressWH) * 0.5;
    CGFloat progressY = (self.frame.size.height - progressWH) * 0.5;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize * 0.5, touchPoint.y - ysize * 0.5, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}


- (void)setAsset:(id)asset {

}


- (void)setModel:(HWBAssetModel *)model {
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    if (model.type == HWBAssetModelMediaTypePhotoGif) {
        [[HWBImageManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            if (!isDegraded) {
                self.imageView.image = [UIImage hwb_animatedGIFWithData:data];
                [self resizeSubviews];
            }
        }];
        
    } else {
        self.asset = model.asset;
    }
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:YES];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    
    CGRect tempRect = _imageContainerView.frame;
    tempRect.origin = CGPointZero;
    tempRect.size.width = self.scrollView.frame.size.width;
    _imageContainerView.frame = tempRect;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.frame.size.height / self.scrollView.frame.size.width) {
        
        tempRect = _imageContainerView.frame;
        tempRect.size.height = floor(image.size.height * self.scrollView.frame.size.width / image.size.width);
        _imageContainerView.frame = tempRect;
        
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.frame.size.width;
        if (height < 1 || isnan(height))
            height = self.frame.size.height;
        height = floor(height);
        tempRect.size.height = height;
        _imageContainerView.frame = tempRect;
        CGPoint center = _imageContainerView.center;
        center.y = self.frame.size.height * 0.5;
        _imageContainerView.center = center;
    }
    
    if (_imageContainerView.frame.size.height > self.frame.size.height && _imageContainerView.frame.size.height - self.frame.size.height <= 1) {
        tempRect.size.height = self.frame.size.height;
        _imageContainerView.frame = tempRect;
    }
    
    CGFloat contentSizeH = MAX(_imageContainerView.frame.size.height, self.frame.size.height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.frame.size.height <= self.frame.size.height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    [self refreshScrollViewContentSize];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _scrollView.maximumZoomScale = allowCrop ? 4.0 : 2.5;
}

- (void)refreshScrollViewContentSize {
    if (_allowCrop) {
        CGFloat contentWidthAdd = self.scrollView.frame.size.width - CGRectGetMaxX(_cropRect);
        CGFloat contentHeightAdd = (MIN(_imageContainerView.frame.size.height, self.frame.size.height) - self.cropRect.size.height) * 0.5;
        CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
        CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.frame.size.height)  + contentHeightAdd;
        _scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
        _scrollView.alwaysBounceVertical = YES;
        if (contentHeightAdd > 0) {
            _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
        } else {
            _scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
}

@end
