//
//  ViewController.m
//  图片选择管理器
//
//  Created by Mac on 17/7/3.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Localized.h"
#import "ImagePickerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@",[NSString localizedStringfForKey:@"Full image"]);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ImagePickerViewController *image = [[ImagePickerViewController alloc] initWithMaxImagesCount:10 delegate:self];
    [self presentViewController:image animated:YES completion:nil];
}



@end
