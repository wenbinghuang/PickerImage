//
//  HWBImageManager.m
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "HWBImageManager.h"
#import "ManagerConfigure.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HWBImageManager ()
#pragma clang diagnostic push
#pragma diagnostic ignored "-Wdeprecated-declarations"
@property(nonatomic, strong)ALAssetsLibrary *assetLibrary;
@end


@implementation HWBImageManager


- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    
    if (iOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetUrls = [NSMutableArray array];
        for (ALAsset *assetItem in assets) {
            [selectedAssetUrls addObject:[assetItem valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetUrls containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
    }
    
}

#pragma clang diagnostic pop
@end
