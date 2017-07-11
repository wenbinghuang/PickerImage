//
//  ImagePickerViewController.m
//  图片选择管理器
//
//  Created by Mac on 17/7/10.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "ManagerConfigure.h"
#import "HWBAssetModel.h"
#import "HWBImageManager.h"
#import "NSString+Localized.h"
#import "PhotoPickerController.h"

@interface ImagePickerViewController () {

    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UIStatusBarStyle _originStatusBarStyle;
}

@property(nonatomic, assign) NSInteger columnNumber;
@end

@implementation ImagePickerViewController
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

/// setup
- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [HWBImageManager manager].shouldFixOrientation = NO;
    
    
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


/// configBarButtonItemAppearance
- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem = nil;
    if (iOS9Later)
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[ImagePickerViewController class]]];
    else
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[ImagePickerViewController class], nil];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    [textAttrs setValue:self.barItemTextColor forKey:NSForegroundColorAttributeName];
    [textAttrs setValue:self.barItemTextFont forKey:NSFontAttributeName];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<ImagePickerControllerDelegate>)delegate {
    return  [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<ImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<ImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    AlbumPickerController *albumPickerVC = [[AlbumPickerController alloc] init];
    albumPickerVC.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVC];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9;
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[HWBImageManager manager] authorizationStatusAuthorized])
            [self setupUnAuthorized];
        else
            [self pushPhotoPickerVC];
    }
    
    return self;
}

/// 没有授权的界面
- (void)setupUnAuthorized {

    _tipLabel = [[UILabel alloc] init];
    _tipLabel.frame = CGRectMake(8, 120, self.view.frame.size.width - 16, 60);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont systemFontOfSize:16.0];
    _tipLabel.textColor = [UIColor blackColor];
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName)
        appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    _tipLabel.text = [NSString localizedStringfForKey:[NSString stringWithFormat:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\"",appName]] ;
    [self.view addSubview:_tipLabel];
    _tipLabel.numberOfLines = 0;
    [_tipLabel sizeToFit];
    _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
    _settingBtn.frame = CGRectMake(0, 180, self.view.frame.size.width, 44);
    _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settingBtn];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
}



- (void)pushPhotoPickerVC {
    
    _didPushPhotoPickerVc = NO;
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        PhotoPickerController *photoPickerVC = [[PhotoPickerController alloc] init];
        photoPickerVC.isFirstAppear = YES;
        photoPickerVC.columnNumber = self.columnNumber;
        [[HWBImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage completion:^(HWBAlbumModel *model) {
            photoPickerVC.model = model;
            [self pushViewController:photoPickerVC animated:YES];
            _didPushPhotoPickerVc = YES;
        }];
    }
}

- (void)observeAuthrizationStatusChange {
    if ([[HWBImageManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVC];
    }
}


- (void)configDefaultSetting {
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    [self configDefaultImageName];
    [self configDefaultBtnTitle];

}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture.png";
    self.photoSelImageName = @"photo_sel_photoPickerVc.png";
    self.photoDefImageName = @"photo_def_photoPickerVc.png";
    self.photoNumberIconImageName = @"photo_number_icon.png";
    self.photoPreviewOriginDefImageName = @"preview_original_def.png";
    self.photoOriginDefImageName = @"photo_original_def.png";
    self.photoOriginSelImageName = @"photo_original_sel.png";
}


- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSString localizedStringfForKey:@"Done"];
    self.cancelBtnTitleStr = [NSString localizedStringfForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSString localizedStringfForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSString localizedStringfForKey:@"Full image"];
    self.settingBtnTitleStr = [NSString localizedStringfForKey:@"Setting"];
    self.processHintStr = [NSString localizedStringfForKey:@"Processing..."];
}

#pragma mark SettingBtnClick
- (void)settingBtnClick {
    if (iOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
            [[UIApplication sharedApplication] openURL:privacyUrl];
        } else {
            NSString *message = [NSString localizedStringfForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString localizedStringfForKey:@"Sorry"] message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *sure = [UIAlertAction actionWithTitle:[NSString localizedStringfForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:sure];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}



/// Set method
- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}


- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    _cropRect = CGRectMake(self.view.bounds.size.width / 2 - circleCropRadius, self.view.bounds.size.height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}


- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
}



- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}





@end



@interface AlbumPickerController()


@end

@implementation AlbumPickerController

#pragma clang diagnostic pop

@end
