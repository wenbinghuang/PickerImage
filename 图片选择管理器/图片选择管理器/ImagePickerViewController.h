//
//  ImagePickerViewController.h
//  图片选择管理器
//
//  Created by Mac on 17/7/10.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWBAssetModel;
@protocol ImagePickerControllerDelegate;

@interface ImagePickerViewController : UINavigationController
- (instancetype)init NS_UNAVAILABLE;

// init
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<ImagePickerControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<ImagePickerControllerDelegate>)delegate;

/// Should PushPhotoPicker
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<ImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;


/// This init method just for previewing photos
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;


/// This init method for crop photo
- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,id asset))completion;






/// Default is 9
@property (nonatomic, assign) NSInteger maxImagesCount;

/// The minimum count photos user must pick, Default is 0
@property (nonatomic, assign) NSInteger minImagesCount;

/// Always enale the done button, not require minimum 1 photo be picked
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;

/// Sort photos ascending by modificationDate，Default is YES
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// Default is 828px
@property (nonatomic, assign) CGFloat photoWidth;

/// Default is 600px
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// Default is 15, While fetching photo, HUD will dismiss automatic if timeout;
@property (nonatomic, assign) NSInteger timeout;






/// Default is YES, if set NO, the original photo button will hide. user can't picking original photo.
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/// Default is YES, if set NO, user can't picking video.
@property (nonatomic, assign) BOOL allowPickingVideo;

/// Default is NO, if set YES, user can picking gif image.
@property (nonatomic, assign) BOOL allowPickingGif;

/// Default is YES, if set NO, user can't picking image.
@property(nonatomic, assign) BOOL allowPickingImage;

/// Default is YES, if set NO, user can't take picture.
@property(nonatomic, assign) BOOL allowTakePicture;

/// Default is YES, if set NO, user can't preview photo.
@property (nonatomic, assign) BOOL allowPreview;

/// Default is YES, if set NO, the picker don't dismiss itself.
@property(nonatomic, assign) BOOL autoDismiss;


/// The photos user have selected
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<HWBAssetModel *> *selectedModels;

/// Minimum selectable photo width, Default is 0
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

/// Hide the photo what can not be selected, Default is NO
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

// Single selection mode, valid when maxImagesCount = 1
@property (nonatomic, assign) BOOL showSelectBtn;

@property (nonatomic, assign) BOOL allowCrop;

@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL needCircleCrop;
@property (nonatomic, assign) NSInteger circleCropRadius;
@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView);

- (void)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;


@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;


@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;


@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;


- (void)cancelButtonClick;


// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[HWBImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)();

// If user picking a video, this handle will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,id asset);


// If user picking a gif image, this callback will be called.
@property (nonatomic, copy) void (^didFinishPickingGifImageHandle)(UIImage *animatedImage,id sourceAssets);

@property (nonatomic, weak) id<ImagePickerControllerDelegate> pickerDelegate;

@end



@protocol ImagePickerControllerDelegate <NSObject>
@optional
// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.

- (void)imagePickerController:(ImagePickerViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;

- (void)imagePickerController:(ImagePickerViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;

- (void)imagePickerControllerDidCancel:(ImagePickerViewController *)picker;

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
- (void)imagePickerController:(ImagePickerViewController *)picker didFinishPickingVideo:(UIImage *)coverImage asset:(id)asset;

// If user picking a gif image, this callback will be called.
- (void)imagePickerController:(ImagePickerViewController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset;

@end


@interface AlbumPickerController : UIViewController
@property (nonatomic, assign) NSInteger columnNumber;
@end

@interface UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;

@end
