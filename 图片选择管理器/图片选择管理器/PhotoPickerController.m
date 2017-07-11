//
//  PhotoPickerController.m
//  图片选择管理器
//
//  Created by Mac on 17/7/11.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PhotoPickerController.h"

@interface PhotoPickerController () {
    NSMutableArray *_models;
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

@implementation PhotoPickerController

@end
