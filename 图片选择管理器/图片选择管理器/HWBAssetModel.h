//
//  HWBAssetModel.h
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAllowPickingImage   @"allowPickingImage"
#define kAllowPickingVideo   @"allowPickingVideo"

///图片枚举类型
typedef enum : NSUInteger {
    HWBAssetModelMediaTypePhoto = 0,
    HWBAssetModelMediaTypeLivePhoto,
    HWBAssetModelMediaTypePhotoGif,
    HWBAssetModelMediaTypeVideo,
    HWBAssetModelMediaTypeAudio
} HWBAssetModelMediaType;

/// HWBAssetModel Class
@interface HWBAssetModel : NSObject

///Properties
@property (nonatomic, strong) id asset;                           ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;                    ///< The select status of a photo, default is No
@property (nonatomic, assign) HWBAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
+ (instancetype)HWBModelWithAsset:(id)asset type:(HWBAssetModelMediaType)type;
+ (instancetype)HWBModelWithAsset:(id)asset type:(HWBAssetModelMediaType)type timeLength:(NSString*)timeLength;

@end



/// HWBAlbumModel Class
@interface HWBAlbumModel : NSObject

///Properties
///The album name
@property (nonatomic, copy)   NSString *name;

///Count of photos the album contain
@property (nonatomic, assign) NSInteger count;
///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, strong) id result;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@end


