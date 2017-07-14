//
//  UIView+Layout.m
//  图片选择管理器
//
//  Created by Mac on 17/7/14.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "UIView+Layout.h"

@implementation UIView (Layout)
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(OscillatoryAnimationType)type {
    NSNumber *animationScale1 = type == OscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == OscillatoryAnimationToBigger ? @(0.92) : @(0.5);
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [layer setValue:animationScale1 forKey:@"transform.scale"];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [layer setValue:animationScale2 forKey:@"transform.scale"];
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
            
        }];
        
    }];
}
@end
