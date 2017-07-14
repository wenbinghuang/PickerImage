//
//  UIView+Layout.h
//  图片选择管理器
//
//  Created by Mac on 17/7/14.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    OscillatoryAnimationToBigger,
    OscillatoryAnimationToSmaller,
} OscillatoryAnimationType;

@interface UIView (Layout)
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(OscillatoryAnimationType)type;
@end
