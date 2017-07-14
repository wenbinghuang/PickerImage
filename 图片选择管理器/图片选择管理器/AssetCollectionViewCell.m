//
//  AssetCollectionViewCell.m
//  图片选择管理器
//
//  Created by Mac on 17/7/12.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "AssetCollectionViewCell.h"
#import "HWBAssetModel.h"
#import "ManagerConfigure.h"
#import "HWBImageManager.h"
#import "UIView+Layout.h"

/*************** AssetCollectionViewCell ***************/
@interface AssetCollectionViewCell ()
@property (weak, nonatomic)     UIImageView *imageView;
@property (weak, nonatomic)     UIImageView *selectImageView;
@property (weak, nonatomic)     UIView      *bottomView;
@property (weak, nonatomic)     UILabel     *timeLengthLabel;
@property (weak, nonatomic)     UIImageView *videoImageView;
@property (assign, nonatomic)   PHImageRequestID bigImageRequestID;
@end

@implementation AssetCollectionViewCell

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    if (!self.selectImageView.hidden)
        self.selectImageView.hidden = !showSelectBtn;
    
    if (!self.selectPhotoButton.hidden)
        self.selectPhotoButton.hidden = !showSelectBtn;
}



- (UIButton *)selectPhotoButton {
    if (!_selectPhotoButton) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        selectPhotoButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.bounds.size.width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}



- (UIView *)bottomView {
    if (!_bottomView) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.bounds.size.height - 17, self.bounds.size.width, 17);
        bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        UIImageView *videoImageView = [[UIImageView alloc] init];
        videoImageView.frame = CGRectMake(8, 0, 17, 17);
        videoImageView.image = [UIImage imageNamed:@"VideoSendIcon.png"];
        [self.bottomView addSubview:videoImageView];
        _videoImageView = videoImageView;
    }
    return _videoImageView;
}

- (UILabel *)timeLengthLabel {
    if (!_timeLengthLabel) {
        UILabel *timeLengthLabel = [[UILabel alloc] init];
        timeLengthLabel.font = [UIFont systemFontOfSize:11];
        timeLengthLabel.frame = CGRectMake(CGRectGetMaxX(self.videoImageView.frame), self.videoImageView.frame.origin.y, self.bottomView.bounds.size.width - CGRectGetMaxX(self.videoImageView.frame) - 5, self.videoImageView.bounds.size.height);
        timeLengthLabel.textColor = [UIColor whiteColor];
        timeLengthLabel.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLengthLabel];
        _timeLengthLabel = timeLengthLabel;
    }
    return _timeLengthLabel;
}


- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock)
        self.didSelectPhotoBlock(sender.isSelected);
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:self.photoSelImageName] : [UIImage imageNamed:self.photoDefImageName];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:OscillatoryAnimationToBigger];
        /// getBigPhoto
        [self fetchBigImage];
    } else {
        /// Cancel The request
        if (_bigImageRequestID)
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
}


- (void)fetchBigImage {
    _bigImageRequestID = [[HWBImageManager manager] getPhotoWithAsset:_model.asset networkAccessAllowed:YES completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
        if (_model.isSelected) {
            self.imageView.alpha = 0.4;
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}


@end


/*************** AlbumTableViewCell ***************/
@interface AlbumTableViewCell ()
@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIImageView *arrowImageView;
@end

@implementation AlbumTableViewCell

- (void)setModel:(HWBAlbumModel *)model {
    _model = model;
    /// 设置Title
    self.titleLabel.attributedText = [self getTitleStringWithModel:model];
    /// 设置缩略图
    [[HWBImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    /// 设置选中的图片数
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd", model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}


- (NSMutableAttributedString *)getTitleStringWithModel:(HWBAlbumModel *)model {
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    return nameString;
}




- (UIImageView *)posterImageView {
    if (!_posterImageView) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, 70, 70);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.frame = CGRectMake(80, 0, self.frame.size.width - 80 - 50, self.frame.size.height);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}


- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGFloat arrowWH = 15;
        arrowImageView.frame = CGRectMake(self.frame.size.width - arrowWH - 12, 28, arrowWH, arrowWH);
        arrowImageView.image = [UIImage imageNamed:@"TableViewArrow.png"];
        [self.contentView addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}


- (UIButton *)selectedCountButton {
    if (!_selectedCountButton) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}


#pragma mark System Method
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.frame.size.width - 24 - 30, 23, 24, 24);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

@end


/*************** AssetCameraCollectionViewCell ***************/
@implementation AssetCameraCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.500];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}
@end
