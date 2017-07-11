//
//  NSString+Localized.m
//  图片选择管理器
//
//  Created by Mac on 17/7/11.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "NSString+Localized.h"

@implementation NSString (Localized)
+ (NSString *)localizedStringfForKey:(NSString *)key {
    return [self localizedStringfForKey:key value:nil];
}


+ (NSString *)localizedStringfForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
    }
    
    return [bundle localizedStringForKey:key value:value table:nil];
    
}
@end
