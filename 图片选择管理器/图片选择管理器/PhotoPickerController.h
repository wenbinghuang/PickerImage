//
//  PhotoPickerController.h
//  图片选择管理器
//
//  Created by Mac on 17/7/11.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWBAlbumModel;
@interface PhotoPickerController : UIViewController
@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) HWBAlbumModel *model;

@property (nonatomic, assign) BOOL isHideTakePhoneButton;
@property (nonatomic, copy) void (^backButtonClickHandle)(HWBAlbumModel *model);
@end
