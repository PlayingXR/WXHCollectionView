//
//  ViewController.m
//  DEMO
//
//  Created by 伍小华 on 2017/12/19.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import "ViewController.h"
#import "WXHCollectionView.h"

@interface ViewController ()<WXHCollectionViewDelegate,WXHCollectionViewDataSource>
@property (nonatomic, strong) WXHCollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, 400);
    self.collectionView.center = self.view.center;
}

#pragma mark - WXHCollectionViewDataSource
- (NSInteger)wxhCollectionView:(WXHCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (__kindof UICollectionViewCell *)wxhCollectionView:(WXHCollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXHCollectionViewDefaultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KWXHCollectionViewDefaultCellIdentifier
                                                                                   forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@(indexPath.item).stringValue];
    return cell;
}
- (void)wxhCollectionView:(WXHCollectionView *)collectionView didScrollToIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didScrollToIndexPath:%li",indexPath.row);
}
- (void)wxhCollectionView:(WXHCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItem:%li",indexPath.row);
    [self.collectionView setCurrentIndex:indexPath.row+1 animated:YES];
}

- (WXHCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[WXHCollectionView alloc] init];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}


@end
