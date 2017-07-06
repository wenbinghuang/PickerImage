//
//  HWBImageCropManager.h
//  图片选择管理器
//
//  Created by Mac on 17/7/6.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HWBImageCropManager : NSObject


/// Get CropImage
+ (void)overlayClippingWithView:(UIView *)view cropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;


/// Get CropImage In Rect
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;

/// Get Circular Image
+ (UIImage *)circularClipImage:(UIImage *)image;

@end


@interface UIImage (HWBGif)

+ (UIImage *)hwb_animatedGIFWithData:(NSData *)data;

@end