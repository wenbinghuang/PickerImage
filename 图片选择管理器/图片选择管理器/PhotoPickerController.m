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
#import "AssetCameraCollectionViewCell.h"
#import "AssetCollectionViewCell.h"

@interface PhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>{
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
    if (imagePickerVC.sortAscendingByModificationDate && _isFirstAppear && iOS8Later) {
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
