//
//  PhotoPreviewCell.m
//  图片选择管理器
//
//  Created by Mac on 17/7/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PhotoPreviewCell.h"
#import "HWBAssetModel.h"

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

}

- (void)doubleTap:(UITapGestureRecognizer *)tap {

}

- (void)singleTap:(UITapGestureRecognizer *)tap {

}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:YES];
    
}



@end
