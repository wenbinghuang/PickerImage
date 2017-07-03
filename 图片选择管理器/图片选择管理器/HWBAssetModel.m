//
//  HWBAssetModel.m
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "HWBAssetModel.h"
#import "HWBImageManager.h"


@implementation HWBAssetModel

+ (instancetype)HWBModelWithAsset:(id)asset type:(HWBAssetModelMediaType)type {
    HWBAssetModel *model = [[HWBAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)HWBModelWithAsset:(id)asset type:(HWBAssetModelMediaType)type timeLength:(NSString *)timeLength {
    HWBAssetModel *model = [self HWBModelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}


@end






@implementation HWBAlbumModel

- (void)setResult:(id)result {
    _result = result;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL allowPickingImage = [[userDefaults objectForKey:kAllowPickingImage] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[userDefaults objectForKey:kAllowPickingVideo] isEqualToString:@"1"];
    HWBImageManager *manager = [HWBImageManager manager];
    [manager getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<HWBAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void) setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}


#pragma mark 检查是否选择了照片
- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
    for (HWBAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    
    for (HWBAssetModel *model in _models) {
        HWBImageManager *manager = [HWBImageManager manager];
        BOOL isContained = [manager isAssetsArray:selectedAssets containAsset:model.asset];
        if (isContained) {
            self.selectedCount ++;
        }
    }
}

@end
