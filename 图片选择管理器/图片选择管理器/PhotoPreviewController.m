//
//  PhotoPreviewController.m
//  图片选择管理器
//
//  Created by Mac on 17/7/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PhotoPreviewController.h"
#import "PhotoPreviewCell.h"

@interface PhotoPreviewController () <UICollectionViewDataSource, UICollectionViewDelegate>{
    UICollectionView *_collectionView;
}

@end

@implementation PhotoPreviewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCollectionView];
}


- (void)configCollectionView {
    
    /// Config LayOut Attribute
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.frame.size.width + 20, self.view.frame.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width + 20, self.view.frame.size.height) collectionViewLayout:layout];;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.frame.size.width + 20), 0);
    [_collectionView registerClass:[PhotoPreviewCell class] forCellWithReuseIdentifier:@"PhotoPreviewCell"];
    [self.view addSubview:_collectionView];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPreviewCell" forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[PhotoPreviewCell class]]) {
        [(PhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[PhotoPreviewCell class]]) {
        [(PhotoPreviewCell *)cell recoverSubviews];
    }
}

@end
