//
//  WXHCollectionView.m
//  DEMO
//
//  Created by 伍小华 on 2017/12/19.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import "WXHCollectionView.h"
#pragma mark - WXHCollectionViewDefaultCell
@implementation WXHCollectionViewDefaultCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
@end
#pragma mark - WXHCollectionView
NSString * const KWXHCollectionViewDefaultCellIdentifier = @"KWXHCollectionViewDefaultCellIdentifier";
@interface WXHCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    BOOL _isAutoCycle;
    BOOL _isDidLoad;
    BOOL _bounces;
    BOOL _scrollEnabled;
    BOOL _isCycleScroll;
    
    NSInteger _itemsMultiple;
    NSInteger _startIndex;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSTimer *autoScrollTimer;

@property (nonatomic, assign) NSInteger itemsCount;

@end
@implementation WXHCollectionView
@synthesize isAutoCycle = _isAutoCycle;
@synthesize scrollEnabled = _scrollEnabled;
@synthesize bounces = _bounces;
@synthesize isCycleScroll = _isCycleScroll;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isCycleScroll = YES;
        _isAutoCycle = YES;
        _bounces = YES;
        _scrollEnabled = YES;
        _isItemsSizeDefault = YES;
        _displayTimeInterval = 3.0;
        _itemsMultiple = 100;
        _startIndex = NSNotFound;
        _scrollDirection = WXHCollectionViewScrollDirectionHorizontalLeft;
    }
    return self;
}
- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _collectionViewLayout = layout;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _isDidLoad = YES;
    
    self.collectionView.frame = self.bounds;
    self.collectionView.scrollEnabled = _scrollEnabled;
    self.collectionView.bounces = _bounces;
    
    if (_isItemsSizeDefault) {
        self.collectionViewLayout.itemSize = self.bounds.size;
    }
    
    UICollectionViewScrollDirection direction;
    if (self.scrollDirection == WXHCollectionViewScrollDirectionHorizontalLeft ||
        self.scrollDirection == WXHCollectionViewScrollDirectionHorizontalRight) {
        direction = UICollectionViewScrollDirectionHorizontal;
    } else {
        direction = UICollectionViewScrollDirectionVertical;
    }
    if (self.collectionViewLayout.scrollDirection != direction) {
        self.collectionViewLayout.scrollDirection = direction;
    }
    
    if (_startIndex != NSNotFound) {
        [self scrollToItemAtIndex:_startIndex animated:NO];
        _startIndex = NSNotFound;
    }
    [self adjustCycleScrollIndex];
    [self startAutoScrollTimer];
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self stopAutoScrollTimer];
    }
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - public
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                          forIndexPath:indexPath];
}
- (void)reloadData
{
    [self.collectionView reloadData];
}
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger count = self.itemsCount;
    count = self.isCycleScroll ? count * _itemsMultiple : count;
    index = index > 0 ? (index >= count ? count -1 : index) : 0;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:animated];
}
#pragma mark - private
- (void)collectionViewDidScroll
{
    NSInteger index = [self currentIndex];
    [self adjustCycleScrollIndex];
    [self startAutoScrollTimer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxhCollectionView:didScrollToIndexPath:)]) {
        [self.delegate wxhCollectionView:self didScrollToIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    }
}
- (void)adjustCycleScrollIndex
{
    if (self.isCycleScroll) {
        NSInteger middleIndex = self.itemsCount * _itemsMultiple * 0.5;
        NSInteger realityIndex = [self realityCurrentIndex];
        NSInteger currentIndex = [self currentIndex];
        
        NSInteger distance = realityIndex-middleIndex;
        if (distance < 0) {
            distance *= -1;
        }
        if (distance*2 > middleIndex) {
            NSInteger index = middleIndex + currentIndex;
            [self scrollToItemAtIndex:index animated:NO];
        }
    }
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *aIndexPath = indexPath;
    if (self.isCycleScroll) {
        NSInteger index = indexPath.item%self.itemsCount;
        aIndexPath = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
    }
    return aIndexPath;
}
- (void)startAutoScrollTimer
{
    if (self.isAutoCycle && _isDidLoad) {
        if (!_autoScrollTimer) {
            [self autoScrollTimer];
        }
    }
}
- (void)stopAutoScrollTimer
{
    if (_autoScrollTimer) {
        if ([_autoScrollTimer isValid]) {
            [_autoScrollTimer invalidate];
        }
        _autoScrollTimer = nil;
    }
}
- (void)autoScrollCollectionView
{
    [self stopAutoScrollTimer];
    NSInteger index = [self realityCurrentIndex];
    
    if (self.scrollDirection == WXHCollectionViewScrollDirectionHorizontalRight ||
        self.scrollDirection == WXHCollectionViewScrollDirectionVerticalDown) {
        index -= 1;
    } else {
        index += 1;
    }
    [self scrollToItemAtIndex:index animated:YES];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.itemsCount;
    if (self.isCycleScroll) {
        count = count * _itemsMultiple;
    }
    return count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *aIndexPath = [self convertIndexPath:indexPath];
    UICollectionViewCell *cell = [self.dataSource wxhCollectionView:self cellForItemAtIndexPath:aIndexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxhCollectionView:didSelectItemAtIndexPath:)]) {
        NSIndexPath *aIndexPath = [self convertIndexPath:indexPath];
        [self.delegate wxhCollectionView:self didSelectItemAtIndexPath:aIndexPath];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopAutoScrollTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self collectionViewDidScroll];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self collectionViewDidScroll];
}

#pragma mark - Setter / Getter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:self.collectionViewLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = self.bounces;
        
        [_collectionView registerClass:[WXHCollectionViewDefaultCell class]
            forCellWithReuseIdentifier:KWXHCollectionViewDefaultCellIdentifier];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)collectionViewLayout
{
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.minimumLineSpacing = 0;
        if (self.scrollDirection == WXHCollectionViewScrollDirectionHorizontalLeft ||
            self.scrollDirection == WXHCollectionViewScrollDirectionHorizontalRight) {
            _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
    }
    return _collectionViewLayout;
}

- (void)setScrollDirection:(WXHCollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        if (_isDidLoad) {
            if (_scrollDirection == WXHCollectionViewScrollDirectionHorizontalLeft ||
                _scrollDirection == WXHCollectionViewScrollDirectionHorizontalRight) {
                _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            } else {
                _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            }
        }
    }
}
- (NSInteger)itemsCount
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(wxhCollectionView:numberOfItemsInSection:)]) {
        _itemsCount = [self.dataSource wxhCollectionView:self numberOfItemsInSection:0];
    } else {
        _itemsCount = 0;
    }
    return _itemsCount;
}

- (NSInteger)currentIndex
{
    NSInteger index = [self realityCurrentIndex];
    index = index % self.itemsCount;
    return index;
}
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    NSInteger realityIndex = [self realityCurrentIndex];
    NSInteger index = [self currentIndex];
    if (currentIndex != index) {
        if (_isDidLoad) {
            if (animated) {
                [self stopAutoScrollTimer];
            }
            NSInteger count = self.itemsCount;
            index = realityIndex / count;
            index *= count;
            index += currentIndex;
            [self scrollToItemAtIndex:index animated:animated];
        } else {
            _startIndex = currentIndex;
        }
    }
}

- (NSInteger)realityCurrentIndex
{
    CGPoint center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    center = [self convertPoint:center toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:center];
    return indexPath.item;
}

- (NSTimer *)autoScrollTimer
{
    if (!_autoScrollTimer) {
        _autoScrollTimer = [NSTimer timerWithTimeInterval:self.displayTimeInterval
                                                   target:self
                                                 selector:@selector(autoScrollCollectionView)
                                                 userInfo:nil
                                                  repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.autoScrollTimer forMode:NSRunLoopCommonModes];
    }
    return _autoScrollTimer;
}

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    if (_isDidLoad) {
        self.collectionView.bounces = bounces;
    }
}
- (BOOL)isAutoCycle
{
    if (self.isCycleScroll) {
        return _isAutoCycle;
    } else {
        return NO;
    }
}
- (void)setIsAutoCycle:(BOOL)isAutoCycle
{
    if (_isAutoCycle != isAutoCycle) {
        _isAutoCycle = isAutoCycle;
        if (_isAutoCycle) {
            [self startAutoScrollTimer];
        } else {
            [self stopAutoScrollTimer];
        }
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    if (_isDidLoad) {
        self.collectionView.scrollEnabled = scrollEnabled;
    }
}
- (void)setIsCycleScroll:(BOOL)isCycleScroll
{
    if (_isCycleScroll != isCycleScroll) {
        _isCycleScroll = isCycleScroll;
        
        if (_isDidLoad) {
            [self reloadData];
        }
        
        if (_isCycleScroll) {
            [self startAutoScrollTimer];
        } else {
            [self stopAutoScrollTimer];
        }
    }
}
- (BOOL)isCycleScroll
{
    if (self.itemsCount > 1) {
        return _isCycleScroll;
    } else {
        return NO;
    }
}
@end
