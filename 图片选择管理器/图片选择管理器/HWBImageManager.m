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
        PHFetchOptions *fetchOption = [self getOptionsWithAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        
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


/// Get All Album
- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HWBAlbumModel *> *))completion {
    
    NSMutableArray *albumArray = [NSMutableArray array];
    if (iOS8Later) {
        PHFetchOptions *fetchOption = [self getOptionsWithAllowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        
        /// My Photo Stream
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        
        /// SmartAlbums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        /// Top Level User
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        /// Synce Albums
        PHFetchResult *synceAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        
        /// Shared Albums
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        
        NSArray *allAlbums = @[myPhotoStreamAlbum, smartAlbums, topLevelUserCollections, synceAlbums, sharedAlbums];
        
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                /// Filter PHCollectionList
                if (![collection isKindOfClass:[PHAssetCollection class]])
                    continue;
                
                PHFetchResult *filterFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOption];
                
                if (filterFetchResult.count < 1)
                    continue;
                
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"])
                    continue;
                
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
                    HWBAlbumModel *model = [self modelWithResult:filterFetchResult name:collection.localizedTitle];
                    [albumArray insertObject:model atIndex:0];
                } else {
                    HWBAlbumModel *model = [self modelWithResult:filterFetchResult name:collection.localizedTitle];
                    [albumArray addObject:model];
                }
            }
        }
        
        if (completion && albumArray.count > 0)
            completion(albumArray);
    } else {
    
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil)
                if (completion && albumArray.count > 0)
                    completion(albumArray);
           
            
            if (group.numberOfAssets < 1)
                return;
        
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            HWBAlbumModel *model = [self modelWithResult:group name:name];
            if ([self isCameraRollAlbum:name]) {
                [albumArray insertObject:model atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                if (albumArray.count) {
                    [albumArray insertObject:model atIndex:1];
                } else {
                    [albumArray addObject:model];
                }
            } else {
                [albumArray addObject:model];
            }
            
        } failureBlock:nil];
    }
}



#pragma mark Get Assets

/// Get Assets
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HWBAssetModel *> *))completion {
    
    NSMutableArray *photoArray = [NSMutableArray array];
    /// PHFetchResult
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult*)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HWBAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model)
               [photoArray addObject:model];
        }];
        if (completion)
            completion(photoArray);
        /// ALAssetsGroup
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        
        if (allowPickingImage && allowPickingVideo)
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        
        else if (allowPickingImage)
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        else if (allowPickingVideo)
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil)
                if (completion)
                    completion(photoArray);
            
            HWBAssetModel *model = [self assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            
            if (model)
                [photoArray addObject:model];
        };
        
        if (self.sortAscendingByModificationDate) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock)
                    resultBlock(result, index, stop);
            }];
        } else {
        
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock)
                    resultBlock(result, index, stop);
            }];
        }
    }
}


#pragma mark Get asset at index
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HWBAssetModel *))completion {
    
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        PHAsset *asset = nil;
        @try {
            asset = fetchResult[index];
        }
        @catch (NSException *exception) {
            if (completion)
                completion(nil);
            return;
        }
        
        HWBAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (completion)
            completion(model);
        
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        
        if (allowPickingImage && allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        } else if (allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        } else if (allowPickingImage) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        @try {
            [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result)
                    return;
                HWBAssetModel *model = [self assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                if (completion)
                    completion(model);
            }];
        }
        @catch (NSException *exception) {
            if (completion)
                completion(nil);
        }
        
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

#pragma mark Check Size 
- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height)
        return NO;
    return YES;
}

#pragma mark Get Size From Asset
- (CGSize)photoSizeWithAsset:(id)asset {
    if (iOS8Later) {
        PHAsset *phAsset = (PHAsset *)asset;
        return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    } else {
        ALAsset *alAsset = (ALAsset*)asset;
        return alAsset.defaultRepresentation.dimensions;
    }
}


#pragma mark Get photo bytes
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *))completion {
    __block NSInteger dataLenth = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        HWBAssetModel *model = photos[i];
        
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            
            PHImageManager *phImageManager = [PHImageManager defaultManager];
            [phImageManager requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                
                if (model.type != HWBAssetModelMediaTypeVideo)
                    dataLenth += imageData.length;
                assetCount ++;
                if (assetCount >= photos.count) {
                    NSString *bytes = [self getBytesFromdataLength:dataLenth];
                    if (completion)
                        completion(bytes);
                }
            }];
            
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != HWBAssetModelMediaTypeVideo)
                dataLenth += (NSInteger)representation.size;
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromdataLength:dataLenth];
                if (completion)
                    completion(bytes);
            }
        }
    }
}


#pragma mark Get Photo
/// Default Size
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    
    HWBImageManager *manager = [HWBImageManager manager];
    CGFloat fullScreenWidth = manager.screenWidth;
    if (fullScreenWidth > self.photoPreviewMaxWidth)
        fullScreenWidth = self.photoPreviewMaxWidth;
    PHImageRequestID imageRequestID = [self getPhotoWithAsset:asset networkAccessAllowed:YES photoWidth:fullScreenWidth completion:completion progressHandler:nil];
    return imageRequestID;
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    
    PHImageRequestID imageRequestID = [self getPhotoWithAsset:asset networkAccessAllowed:YES photoWidth:photoWidth completion:completion progressHandler:nil];
    return imageRequestID;
}


- (PHImageRequestID)getPhotoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler {

    HWBImageManager *manager = [HWBImageManager manager];
    CGFloat fullScreenWidth = manager.screenWidth;
    if (fullScreenWidth > self.photoPreviewMaxWidth)
        fullScreenWidth = self.photoPreviewMaxWidth;
    PHImageRequestID imageRequestID = [self getPhotoWithAsset:asset networkAccessAllowed:networkAccessAllowed photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler];
    return imageRequestID;
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler {
    
    HWBImageManager *manager = [HWBImageManager manager];
    CGSize imageSize = CGSizeZero;
    if ([asset isKindOfClass:[PHAsset class]]) {
    
        if (photoWidth < manager.screenWidth && photoWidth < self.photoPreviewMaxWidth) {
            imageSize = manager.assetGridThumbnailSize;
        } else {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRadio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * manager.screenScale;
            CGFloat pixelHeight = pixelWidth / aspectRadio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestID imageRequestID = [imageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![[info objectForKey:PHImageErrorKey] boolValue]);
            
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                if (completion)
                    completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            
            
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       if (progressHandler)
                           progressHandler(progress, error, stop, info);
                    });
                };
                
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                   
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (resultImage) {
                        resultImage = [self fixOrientation:resultImage];
                        if (completion)
                            completion(resultImage, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
                }];
            }
            
        }];
        return imageRequestID;
            
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        
        ALAsset *alAsset = (ALAsset *)asset;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            CGImageRef thumnailImageRef = alAsset.thumbnail;
            UIImage *thumnailImage = [UIImage imageWithCGImage:thumnailImageRef scale:2.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completion) completion(thumnailImage, nil, YES);
                if (photoWidth == manager.screenWidth || photoWidth == self.photoPreviewMaxWidth) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        
                        ALAssetRepresentation *representation = alAsset.defaultRepresentation;
                        CGImageRef fullScreenImageRef = representation.fullScreenImage;
                        UIImage *fullScreenImage = [UIImage imageWithCGImage:fullScreenImageRef scale:2.0 orientation:UIImageOrientationUp];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(fullScreenImage, nil, NO);
                        });
                    });
                }
            });
            
        });
    }
    return 0;

}


#pragma mark Get postImage
- (void)getPostImageWithAlbumModel:(HWBAlbumModel *)model completion:(void (^)(UIImage *))completion {
    
    if (iOS8Later) {
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate)
            asset = [model.result firstObject];
        HWBImageManager *manager = [HWBImageManager manager];
        [manager getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion)
                completion(photo);
        }];
    } else {
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
        if (completion)
            completion(postImage);
    }
}


#pragma mark Get Original Photo
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *))completion {
    [self getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo, info);
        }
    }];
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

- (HWBAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    
    HWBAssetModel *model = nil;
    HWBAssetModelMediaType type = HWBAssetModelMediaTypePhoto;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo)
            type = HWBAssetModelMediaTypeVideo;
        else if (phAsset.mediaType == PHAssetResourceTypeAudio)
            type = HWBAssetModelMediaTypeAudio;
        else if (phAsset.mediaType == PHAssetMediaTypeImage) {
            if (iOS9_1Later)
                if (phAsset.mediaSubtypes == PHAssetMediaSubtypePhotoLive)
                    type = HWBAssetModelMediaTypeLivePhoto;
            if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"])
                type = HWBAssetModelMediaTypePhotoGif;
        }
        
        if (!allowPickingImage && type == HWBAssetModelMediaTypePhoto)
            return model;
        if (!allowPickingVideo && type == HWBAssetModelMediaTypeVideo)
            return model;
        if (self.hideWhenCanNotSelect)
            if (![self isPhotoSelectableWithAsset:phAsset])
                return model;
        NSString *timeLength = type == HWBAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        model =  [HWBAssetModel HWBModelWithAsset:asset type:type timeLength:timeLength];
    } else {
        if (!allowPickingVideo) {
            model = [HWBAssetModel HWBModelWithAsset:asset type:type];
            return model;
        }
        
        /// Allow Picking Video
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString: ALAssetTypeVideo]) {
            type = HWBAssetModelMediaTypeVideo;
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] integerValue];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            model = [HWBAssetModel HWBModelWithAsset:asset type:type timeLength:timeLength];
        } else {
            if (self.hideWhenCanNotSelect)
                if (![self isPhotoSelectableWithAsset:asset])
                    return model;
            model = [HWBAssetModel HWBModelWithAsset:asset type:type];
        }
        
    }
    return model;
}

#pragma mark Get PHFetchOptions
- (PHFetchOptions*)getOptionsWithAllowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    if (!allowPickingImage)
        fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    
    if (!allowPickingVideo)
        fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    /// Fetch all. use PHAsset [PHAsset fetchAssetsWithOptions:options];
    if (!self.sortAscendingByModificationDate)
        fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    
    return fetchOption;
}

#pragma mark Get Time Of String
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime = nil;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - min * 60;
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min, sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min, sec];
        }
    }
    return newTime;
}

#pragma mark Get Data Length
- (NSString *)getBytesFromdataLength:(NSInteger)dataLength {
    NSString *bytes = nil;
    if (dataLength >= 0.1 * (1024 * 1024))
        bytes = [NSString stringWithFormat:@"%0.1fM", dataLength / (1024 * 1024.0)];
    else if (dataLength > 1024)
        bytes = [NSString stringWithFormat:@"%0.0fK", dataLength / 1024.0];
    else
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    
    return bytes;
    
}


#pragma mark fixOrientation of Image
- (UIImage *)fixOrientation: (UIImage*)aImage {
    
    if (!self.shouldFixOrientation)
        return aImage;
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
           
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height, CGImageGetBitsPerComponent(aImage.CGImage), 0, CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImageRef];
    CGContextRelease(ctx);
    CGImageRelease(cgImageRef);
    return image;
    
}

#pragma mark Get Scale Size Image
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {

    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawAsPatternInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    return image;
}

#pragma clang diagnostic pop
@end
