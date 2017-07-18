//
//  PhotoPickerController.m
//  图片选择管理器
//
//  Created by Mac on 17/7/11.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PhotoPickerController.h"
#import "ManagerConfigure.h"
#import "ImagePickerViewController.h"
#import "HWBAssetModel.h"
#import "HWBImageManager.h"
#import "NSString+Localized.h"
#import "AssetCollectionViewCell.h"
#import "UIView+Layout.h"
#import "VideoPlayerController.h"
#import "GifPhotoViewController.h"
#import "PhotoPreviewController.h"

@interface PhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    NSMutableArray <HWBAssetModel *>*_models;
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UIButton *_originalPhotoLabel;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    
}
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelecOriginalPhoto;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) CollectionView *collectionView;

@end

static CGSize AssetGridThumbnailSize;

@implementation PhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (UIImagePickerController *)imagePickerVc {
    if (!_imagePickerVc) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        _imagePickerVc.delegate = self;
        
        UIBarButtonItem *BarItem = nil;
        UIBarButtonItem *ImageBarItem = nil;
        if (iOS9Later) {
            ImageBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[ImagePickerViewController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            ImageBarItem = [UIBarButtonItem appearanceWhenContainedIn:[ImagePickerViewController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        
        NSDictionary *titleTextAttributes = [ImageBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    
    return _imagePickerVc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollCollectionViewToBottom];
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600)
        scale = 1.0;
    CGSize cellSize = ((UICollectionViewFlowLayout *)(_collectionView.collectionViewLayout)).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS8Later) {
        
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    imagePickerVC.isSelectOriginalPhoto = _isSelecOriginalPhoto;
    if (self.backButtonClickHandle)
        self.backButtonClickHandle(_model);
}

#pragma mark setup
- (void)setup {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    _isSelecOriginalPhoto = imagePickerVC.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString localizedStringfForKey:imagePickerVC.cancelBtnTitleStr] style:UIBarButtonItemStylePlain target:imagePickerVC action:@selector(cancelButtonClick)];
    
    _showTakePhotoBtn = (imagePickerVC.allowTakePicture && [[HWBImageManager manager] isCameraRollAlbum:_model.name]);
    [_models removeAllObjects];
    _models = nil;
    if (!imagePickerVC.sortAscendingByModificationDate && _isFirstAppear && iOS8Later) {
        [[HWBImageManager manager] getCameraRollAlbum:imagePickerVC.allowPickingVideo allowPickingImage:imagePickerVC.allowPickingImage completion:^(HWBAlbumModel *model) {
            _model = model;
            _models = [NSMutableArray arrayWithArray:model.models];
            [self initSubviews];
            
        }];
    } else {
    
        if (_showTakePhotoBtn || !iOS8Later || _isFirstAppear) {
            [[HWBImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:imagePickerVC.allowPickingVideo allowPickingImage:imagePickerVC.allowPickingImage completion:^(NSArray<HWBAssetModel *> *models) {
                _models = [NSMutableArray arrayWithArray:models];
                [self initSubviews];
            }];
            
        } else {
            _models = [NSMutableArray arrayWithArray:_model.models];
            [self initSubviews];
        }
    }
}

- (void)initSubviews {
    [self checkSelectedModels];
    [self configCollectionView];
    [self configBottomToolBar];
}

- (void)checkSelectedModels {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    for (HWBAssetModel *model in _models) {
        model.isSelected = NO;
        if ([[HWBImageManager manager] isAssetsArray:imagePickerVC.selectedModels containAsset:model.asset]) {
            model.isSelected = YES;
        }
    }
}

- (void)configCollectionView {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *) self.navigationController;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWH = (self.view.frame.size.width - (self.columnNumber + 1) * margin ) / self.columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    CGFloat top = 44;
    if (iOS7Later)
        top += 20;
    CGFloat collectionViewHeight = imagePickerVC.showSelectBtn ? self.view.frame.size.height - 50 - top : self.view.frame.size.height - top;
    _collectionView = [[CollectionView alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    if (_showTakePhotoBtn && imagePickerVC.allowTakePicture) {
        _collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.frame.size.width);
    } else {
     _collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((_model.count - 1 + self.columnNumber) / self.columnNumber) * self.view.frame.size.width);
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[AssetCameraCollectionViewCell class] forCellWithReuseIdentifier:@"AssetCameraCollectionViewCell"];
    [_collectionView registerClass:[AssetCollectionViewCell class] forCellWithReuseIdentifier:@"AssetCollectionViewCell"];
}

- (void)configBottomToolBar {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    if (!imagePickerVC.showSelectBtn) return;
}

#pragma mark UICollectionViewDataSource && Delegate 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showTakePhotoBtn) {
        ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
        if (imagePickerVC.allowPickingImage && imagePickerVC.allowTakePicture)
            return _models.count + 1;
    }
    return _models.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    /// the cell lead to take a picture
    if (((imagePickerVC.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!imagePickerVC.sortAscendingByModificationDate && indexPath == 0)) && _showTakePhotoBtn) {
        AssetCameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCameraCollectionViewCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:imagePickerVC.takePictureImageName];
        return cell;
    }
    
    /// the cell dipaly photo or video
    AssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCollectionViewCell" forIndexPath:indexPath];
    cell.photoDefImageName = imagePickerVC.photoDefImageName;
    cell.photoSelImageName = imagePickerVC.photoSelImageName;
    HWBAssetModel * model = nil;
    if (imagePickerVC.sortAscendingByModificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.allowPickingGif = imagePickerVC.allowPickingGif;
    cell.model = model;
    cell.showSelectBtn = imagePickerVC.showSelectBtn;
    
    if (!imagePickerVC.allowPreview)
        cell.selectPhotoButton.frame = cell.bounds;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        ImagePickerViewController *imagePickerViewController = (ImagePickerViewController *)weakSelf.navigationController;
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:imagePickerViewController.selectedModels];
            for (HWBAssetModel *model_item in selectedModels) {
                if ([[[HWBImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[HWBImageManager manager] getAssetIdentifier:model_item.asset]]) {
                    [imagePickerViewController.selectedModels removeObject:model_item];
                    break;
                }
            }
            [weakSelf refreshBottomToolBarStatus];
        } else {
            if (imagePickerViewController.selectedModels.count < imagePickerViewController.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [imagePickerViewController.selectedModels addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                NSString *title = [NSString stringWithFormat:[NSString localizedStringfForKey:@"Select a maximum of %zd photos"], imagePickerViewController.maxImagesCount];
                [imagePickerViewController showAlertWithTitle:title];
            }
        }
        [UIView showOscillatoryAnimationWithLayer:weakLayer type:OscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)refreshBottomToolBarStatus {

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    /// take a photo
    if (((imagePickerVC.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!imagePickerVC.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn) {
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (!imagePickerVC.sortAscendingByModificationDate && _showTakePhotoBtn) {
        index = indexPath.row - 1;
    }
    HWBAssetModel *model = _models[index];
    if (model.type == HWBAssetModelMediaTypeVideo) {
        
        if (imagePickerVC.selectedModels.count > 0) {
             [imagePickerVC showAlertWithTitle:[NSString localizedStringfForKey:@"Can not choose both video and photo"]];
        } else {
            VideoPlayerController *videoPlayerVc = [[VideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
        
    } else if (model.type == HWBAssetModelMediaTypePhotoGif && imagePickerVC.allowPickingGif) {
    
        if (imagePickerVC.selectedModels.count > 0) {
            [imagePickerVC showAlertWithTitle:[NSString localizedStringfForKey:@"Can not choose both photo and GIF"]];
        } else {
            GifPhotoViewController *gifPreViewVC = [[GifPhotoViewController alloc] init];
            gifPreViewVC.model = model;
            [self.navigationController pushViewController:gifPreViewVC animated:YES];
        }
    } else {
        PhotoPreviewController *photoPreviewVc = [[PhotoPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

- (void)pushPhotoPrevireViewController:(PhotoPreviewController *)photoPreviewVC {
    __weak typeof(self) weakSelf = self;
    photoPreviewVC.isSelectOriginalPhoto = _isSelecOriginalPhoto;
    
    [photoPreviewVC setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelecOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    }];
    
    [photoPreviewVC setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelecOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf doneButtonClick];
    }];
    
    
    [photoPreviewVC setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        [weakSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVC animated:YES];
}

- (void)doneButtonClick {

}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    ImagePickerViewController *imagePickerVc = (ImagePickerViewController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    
    if (imagePickerVc.autoDismiss) {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }];
        
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    ImagePickerViewController *imagePickerVC = (ImagePickerViewController *)self.navigationController;
    
    if ([imagePickerVC.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
        [imagePickerVC.pickerDelegate imagePickerController:imagePickerVC didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelecOriginalPhoto];
    }
    
    if ([imagePickerVC.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
        [imagePickerVC.pickerDelegate imagePickerController:imagePickerVC didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelecOriginalPhoto infos:infoArr];
    }
    
    
    if (imagePickerVC.didFinishPickingPhotosHandle) {
        imagePickerVC.didFinishPickingPhotosHandle(photos, assets, _isSelecOriginalPhoto);
    }
    
    if (imagePickerVC.didFinishPickingPhotosWithInfosHandle) {
        imagePickerVC.didFinishPickingPhotosWithInfosHandle(photos, assets, _isSelecOriginalPhoto, infoArr);
    }
}

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        [self showMessage];
        
    } else {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            self.imagePickerVc.sourceType = sourceType;
            if (iOS8Later) {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController: self.imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}


- (void)showMessage {
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    NSString *message = [NSString stringWithFormat:[NSString localizedStringfForKey:@"Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""], appName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString localizedStringfForKey:@"Can not use camera"] message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSString localizedStringfForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:[NSString localizedStringfForKey:@"Setting"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (iOS8Later) {
            BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            if (canOpen) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        } else {
            NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                NSString *message = [NSString localizedStringfForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:[NSString localizedStringfForKey:@"Sorry"] message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *canCel = [UIAlertAction actionWithTitle:[NSString localizedStringfForKey:@"Sorry"] style:UIAlertActionStyleCancel handler:nil];
                [controller addAction:canCel];
                [self presentViewController:controller animated:YES completion:nil];
                
            }
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)scrollCollectionViewToBottom {
    
}




#pragma clang diagnostic pop
@end




@implementation CollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]])
        return  YES;
    return [super touchesShouldCancelInContentView:view];
}

@end
