//
//  WXHCollectionView.h
//  DEMO
//
//  Created by 伍小华 on 2017/12/19.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXHCollectionViewScrollDirection) {
    WXHCollectionViewScrollDirectionHorizontalLeft = 0,
    WXHCollectionViewScrollDirectionHorizontalRight,
    WXHCollectionViewScrollDirectionVerticalUp,
    WXHCollectionViewScrollDirectionVerticalDown
};

@interface WXHCollectionViewDefaultCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end

UIKIT_EXTERN NSString * const KWXHCollectionViewDefaultCellIdentifier;
@class WXHCollectionView;

@protocol WXHCollectionViewDataSource <NSObject>
- (NSInteger)wxhCollectionView:(WXHCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (__kindof UICollectionViewCell *)wxhCollectionView:(WXHCollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol WXHCollectionViewDelegate <NSObject>
@optional
- (void)wxhCollectionView:(WXHCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)wxhCollectionView:(WXHCollectionView *)collectionView didScrollToIndexPath:(NSIndexPath *)indexPath;
@end

@interface WXHCollectionView : UIView
@property (nonatomic, assign) NSTimeInterval displayTimeInterval;                //default 3s
@property (nonatomic, assign) BOOL isCycleScroll;                                //default YES
@property (nonatomic, assign) BOOL isAutoCycle;                                  //default YES
@property (nonatomic, assign) BOOL bounces;                                      //default YES
@property (nonatomic, assign) BOOL scrollEnabled;                                //default YES

@property (nonatomic, assign) BOOL isItemsSizeDefault;                           //default YES
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, assign) WXHCollectionViewScrollDirection scrollDirection;   //default WXHCollectionViewScrollDirectionHorizontalLeft

@property (nonatomic, weak) id<WXHCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<WXHCollectionViewDataSource> dataSource;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndexPath:(NSIndexPath *)indexPath;

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;
- (void)reloadData;
@end


