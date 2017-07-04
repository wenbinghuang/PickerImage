//
//  HWBImageManager.h
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>



@class HWBAlbumModel, HWBAssetModel;
@interface HWBImageManager : NSObject
/// Properties
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

/// 图片是否需要修正方向
@property (nonatomic, assign) BOOL shouldFixOrientation;

/// Default is 600px
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// Default is 4, Use in photos collectionView in HWBPhotoPickerController
@property (nonatomic, assign) NSInteger columnNumber;

/// Sort photos ascending by modificationDate，Default is YES
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// /// Minimum selectable photo width, Default is 0
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

/// Single Method
+ (instancetype)manager;


/// Return YES if Authorized
- (BOOL)authorizationStatusAuthorized;

/// Get Authorization State
- (NSInteger)authorizationStatus;




/// Get Album
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HWBAlbumModel *model))completion;

- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HWBAlbumModel *> *models))completion;



/// Get Assets
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HWBAssetModel *> *models))completion;

- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HWBAssetModel *model))completion;



/// Get photo
- (void)getPostImageWithAlbumModel:(HWBAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

- (PHImageRequestID)getPhotoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;



/// Get full Image
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;


/// Get video
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

/// Export video
- (void)getVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath))completion;

/// Get photo bytes
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

/// Save photo
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

/// Judge is a assets array contain the asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;


- (NSString *)getAssetIdentifier:(id)asset;
- (BOOL)isCameraRollAlbum:(NSString *)albumName;

/// Check is suitable to selecet
- (BOOL)isPhotoSelectableWithAsset:(id)asset;
- (CGSize)photoSizeWithAsset:(id)asset;

@end
