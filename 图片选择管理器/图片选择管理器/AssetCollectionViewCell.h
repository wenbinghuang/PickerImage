//
//  AssetCollectionViewCell.h
//  图片选择管理器
//
//  Created by Mac on 17/7/12.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    AssetCollectionViewCellTypePhoto = 0,
    AssetCollectionViewCellTypeLivePhoto,
    AssetCollectionViewCellTypePhotoGif,
    AssetCollectionViewCellTypeVideo,
    AssetCollectionViewCellTypeAudio,
} AssetCollectionViewCellType;

@class HWBAssetModel;
@interface AssetCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong)HWBAssetModel *model;
@property (nonatomic,copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic,assign) AssetCollectionViewCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@property (nonatomic, copy)NSString *photoSelImageName;
@property (nonatomic, copy)NSString *photoDefImageName;
@property (nonatomic, assign) BOOL showSelectBtn;


@end


@class HWBAlbumModel;
@interface AlbumTableViewCell : UITableViewCell
@property (nonatomic, strong) HWBAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;
@end



@interface AssetCameraCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end
