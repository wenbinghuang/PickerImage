//
//  HWBImageCropManager.m
//  图片选择管理器
//
//  Created by Mac on 17/7/6.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "HWBImageCropManager.h"
#import <ImageIO/ImageIO.h>

@implementation HWBImageCropManager

@end


@implementation UIImage(HWBGif)

+ (UIImage *)hwb_animatedGIFWithData:(NSData *)data {

    UIImage *animatedImage = nil;
    if (!data)
        return animatedImage;
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1)
        animatedImage = [UIImage imageWithData:data];
    else {
        
    }
    
    
    
    return animatedImage;
}

+ (float)frameDurationAtindex:(NSInteger)index source:(CGImageSourceRef)source {

    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)(cfFrameProperties);
     NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
     NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

@end