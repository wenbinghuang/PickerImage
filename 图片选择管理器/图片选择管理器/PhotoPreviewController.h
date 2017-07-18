//
//  PhotoPreviewController.h
//  图片选择管理器
//
//  Created by Mac on 17/7/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPreviewController : UIViewController
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) BOOL isCropImage;

@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,id asset);
@property (nonatomic, copy) void (^doneButtonClickBlockWithPreviewType)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@end
