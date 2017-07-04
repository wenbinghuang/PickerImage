//
//  HWBImageManager.m
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "HWBImageManager.h"
#import "ManagerConfigure.h"
#import "HWBAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HWBImageManager ()
#pragma clang diagnostic push
#pragma diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, assign) CGSize assetGridThumbnailSize;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenScale;
@end


@implementation HWBImageManager


#pragma mark Single mehod
+ (instancetype)manager {
    static HWBImageManager *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[HWBImageManager alloc] init];
        if (iOS8Later) {
            manger.cachingImageManager = [[PHCachingImageManager alloc] init];
            manger.cachingImageManager.allowsCachingHighQualityImages = YES;
            manger.screenWidth = [UIScreen mainScreen].bounds.size.width;
            manger.screenScale = 2.0;
            if (manger.screenWidth > 700) {
                manger.screenScale = 1.5;
            }
        }
    });
    return manger;
}

#pragma mark Set method
- (void) setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    HWBImageManager *manager = [HWBImageManager manager];
    CGFloat itemWH = ((manager.screenWidth - 2 * margin - 4) / columnNumber - margin) * manager.screenScale;
    manager.assetGridThumbnailSize = CGSizeMake(itemWH, itemWH);
}


#pragma mark Get method
- (ALAssetsLibrary *)assetLibrary {

    if (!_assetLibrary) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}


#pragma mark  Check authorized
- (BOOL)authorizationStatusAuthorized {
    if (iOS8Later) {
        return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
    } else {
        return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized;
    }
}

#pragma mark Get Authorized Status
- (NSInteger)authorizationStatus {
    if (iOS8Later) {
        return [PHPhotoLibrary authorizationStatus];
    } else {
        return [ALAssetsLibrary authorizationStatus];
    }
}

#pragma mark check ContainAsset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    
    if (iOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetUrls = [NSMutableArray array];
        for (ALAsset *assetItem in assets) {
            [selectedAssetUrls addObject:[assetItem valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetUrls containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
    }
    
}

#pragma mark Get Album
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HWBAlbumModel *))completion {
    __block HWBAlbumModel *model;
    
    if (iOS8Later) {
        PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
        if (!allowPickingVideo) {
            fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
        }
        
        if (!allowPickingImage) {
            fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
        }
        
        /// Fetch all. use PHAsset [PHAsset fetchAssetsWithOptions:options];
        if (!self.sortAscendingByModificationDate) {
            fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        
        
        
        /// Fetch SmartAlbums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        for (PHAssetCollection *collection in smartAlbums) {
            if (![collection isKindOfClass:[PHAssetCollection class]])
                continue;
            
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOption];
                model = [self modelWithResult:fetchResult name:collection.localizedTitle];
                if (completion)
                    completion(model);
                break;
            }
        }
        
    } else {
    
        [self.assetLibrary enumerateGroupsWithTypes: ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group.numberOfAssets < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name]) {
                model = [self modelWithResult:group name:name];
                if (completion)
                    completion(model);
                *stop = YES;
            }
        } failureBlock:nil];
    }
}


#pragma mark Check IsCamaraRollAlbum
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1)
        versionStr = [versionStr stringByAppendingString:@"00"];
    else if (versionStr.length <= 2)
        versionStr = [versionStr stringByAppendingString:@"0"];
    CGFloat version = versionStr.floatValue;
    if (version >= 800 && version <= 802)
        return ([albumName isEqualToString:@"Recently Added"] || [albumName isEqualToString:@"最近添加"]);
    else
        return ([albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"All Photos"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] );
}

#pragma mark Private Method
- (HWBAlbumModel *)modelWithResult:(id)result name:(NSString *)name {
    HWBAlbumModel *model = [[HWBAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult*)result;
        model.count = fetchResult.count;
        
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *assetsGroup = (ALAssetsGroup*)result;
        model.count = assetsGroup.numberOfAssets;
    }
    return model;
}

#pragma clang diagnostic pop
@end
