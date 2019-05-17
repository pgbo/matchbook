//
//  MBPageStatusKit.m
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBPageStatusKit.h"
#import "MBSpecs.h"
#import "Masonry.h"

@interface MBDataRequestStatusView (MBPageStatusKit) <LFPageInformationDisplayView>

@end

@implementation MBDataRequestStatusView (MBPageStatusKit)

#pragma mark - LFPageInformationDisplayView

- (BOOL)lfpi_hideBeforeAddIntoContainerView {
    return YES;
}

- (BOOL)lfpi_aliginCenter  {
    return YES;
}

- (BOOL)lfpi_removeFromSuperViewWhenHide {
    return YES;
}

- (CGSize)lfpi_intrinsicContentSize {
    return [self intrinsicContentSize];
}

@end


@interface MBPageStatusTouchView : UIView<LFPageInformationDisplayView>

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL touchable;
@property (nonatomic, copy) void(^touchBlock)();
- (void)executeTouchBlock;

@end

@implementation MBPageStatusTouchView

#pragma makk - LFPageInformationDisplayView

- (BOOL)lfpi_hideBeforeAddIntoContainerView {
    return YES;
}

- (BOOL)lfpi_aliginCenter {
    return YES;
}

- (BOOL)lfpi_removeFromSuperViewWhenHide {
    return YES;
}

- (CGSize)lfpi_intrinsicContentSize {
    return self.contentSize;
}

- (void)executeTouchBlock {
    if (_touchable && _touchBlock) _touchBlock();
}

@end


@interface MBPageStatusKit () <LFPageInformationDisplayItemDelegate>

// 容器视图
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic) LFPageInformationDisplayItem *loadingDisplayItem;
@property (nonatomic, weak) MBDataRequestStatusView *loadingStatusView;
@property (nonatomic, weak) MBPageStatusTouchView *loadingTouchView;

@property (nonatomic) LFPageInformationDisplayItem *noDataDisplayItem;
@property (nonatomic, weak) MBDataRequestStatusView *noDataStatusView;
@property (nonatomic, weak) MBPageStatusTouchView *noDataTouchView;

@property (nonatomic) LFPageInformationDisplayItem *noNetworkDisplayItem;
@property (nonatomic, weak) MBDataRequestStatusView *noNetworkStatusView;
@property (nonatomic, weak) MBPageStatusTouchView *noNetworkTouchView;

@property (nonatomic) LFPageInformationDisplayItem *normalErrorDisplayItem;
@property (nonatomic, weak) MBDataRequestStatusView *normalErrorStatusView;
@property (nonatomic, weak) MBPageStatusTouchView *normalErrorTouchView;

@end

@implementation MBPageStatusKit

- (instancetype)initWithContainerView:(UIView *)containerView {
    NSAssert(containerView != nil, @"containerView can't be nil.");
    if (self = [super init]) {
        self.containerView = containerView;
        self.containerSize = containerView.bounds.size;
        
        UIFont *defaultFont = [MBFontSpecs regular];
        UIColor *defaultColor = [MBColorSpecs app_mainTextColor];
        
        self.loadingText = [self.class createAttributedTextWithText:@"加载中..."
                                                               font:defaultFont
                                                          textColor:defaultColor];
        
        self.noDataTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
            return
            [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"暂无数据\n点击屏幕重试":@"暂无数据"
                                                     font:defaultFont
                                                textColor:defaultColor];
        };
        self.noDataViewTouchable = YES;
        
        self.noNetworkTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
            return
            [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"网络状态待提升\n点击屏幕重试":@"网络状态待提升"
                                                     font:defaultFont
                                                textColor:defaultColor];
        };
        self.noNetworkViewTouchable = YES;
        
        self.normalErrorTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
            return
            [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"Sorry, 貌似出错了\n点击屏幕重试":@"Sorry, 貌似出错了"
                                                     font:defaultFont
                                                textColor:defaultColor];
        };
        self.normalErrorViewTouchable = YES;
    }
    return self;
}

+ (LFPageInformationDisplayItem *)createDisplayItemWithContainerView:(UIView *)containerView
                                               statusViewConstructor:(void(^)(MBDataRequestStatusView *statusView))statusViewConstructor
                                                touchViewConstructor:(void(^)(MBPageStatusTouchView *touchView))touchViewConstructor {
    
    /**
     *  创建如下结构的视图，给 ｀TouchView｀添加点击手势，达到可以点击屏幕
     *   ____________________
     *  |      TouchView     |
     *  |  ________________  |
     *  | |                | |
     *  | |   statusView   | |
     *  | |________________| |
     *  |____________________|
     */
    
    MBDataRequestStatusView *statusView = [[MBDataRequestStatusView alloc] init];
    MBPageStatusTouchView *touchView = [[MBPageStatusTouchView alloc]initWithFrame:containerView.bounds];
    [containerView addSubview:touchView];
    [touchView addSubview:statusView];
    
    if (statusViewConstructor) {
        statusViewConstructor(statusView);
    }
    if (touchViewConstructor) {
        touchViewConstructor(touchView);
    }
    
    CGSize statusViewIntrinsicSize = statusView.lfpi_intrinsicContentSize;
    BOOL aligenCenter = statusView.lfpi_aliginCenter;
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(statusViewIntrinsicSize.width);
        make.height.mas_equalTo(statusViewIntrinsicSize.height);
        if (aligenCenter) {
            make.center.mas_equalTo(CGPointZero);
        } else {
            make.leading.mas_equalTo(0);
            make.top.mas_equalTo(0);
        }
    }];
    
    LFPageInformationDisplayItem *displayItem = [[LFPageInformationDisplayItem alloc]initWithPageInformationDisplayView:touchView pageInformationContainerView:containerView];
    displayItem.pageInformationAnimation = ({
        LFPageInformationSimpleAnimation *animation =[[LFPageInformationSimpleAnimation alloc]init];
        animation.informationDisplayView = touchView;
        animation;
    });
    
    return displayItem;
}

/**
 *  除了 `butItem` 其他都隐藏
 */
- (void)hideAllBut:(LFPageInformationDisplayItem *)butItem {
    if (_loadingDisplayItem != butItem) {
        [_loadingDisplayItem hideWithAnimated:NO];
    }
    
    if (_noDataDisplayItem != butItem) {
        [_noDataDisplayItem hideWithAnimated:NO];
    }
    
    if (_noNetworkDisplayItem != butItem) {
        [_noNetworkDisplayItem hideWithAnimated:NO];
    }
    if (_normalErrorDisplayItem != butItem) {
        [_normalErrorDisplayItem hideWithAnimated:NO];
    }
}

+ (MBDataRequestStatusViewLayout *)defaultStatusViewLayout {
    MBDataRequestStatusViewLayout *defualtLayout = [MBDataRequestStatusViewLayout new];
    defualtLayout.width = 0;
    defualtLayout.imageViewInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    defualtLayout.imageViewHeight = 0;
    defualtLayout.textLabelInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    return defualtLayout;
}

- (LFPageInformationDisplayItem *)loadingDisplayItem {
    if (!_loadingDisplayItem) {
        __weak typeof(self)weakSelf = self;
        _loadingDisplayItem = [self.class createDisplayItemWithContainerView:self.containerView statusViewConstructor:^(MBDataRequestStatusView *statusView) {
            if (!weakSelf) return;
            weakSelf.loadingStatusView = statusView;
            
            statusView.textLabel.attributedText = weakSelf.loadingText;
            
            CGFloat imageViewHeight = [weakSelf.class statusView:statusView updateWithImages:[weakSelf loadingImages]];
            
            MBDataRequestStatusViewLayout *layout = [[weakSelf.class defaultStatusViewLayout] copy];
            layout.width = weakSelf.containerSize.width;
            layout.imageViewHeight = imageViewHeight;
            layout.textLabelInsets = ({
                UIEdgeInsets inset = layout.textLabelInsets;
                inset.top = imageViewHeight==0?0:16;
                inset;
            });
            statusView.layout = layout;
            
            [weakSelf.class invalidateIntrinsicContentSizeForStatusView:statusView];
            
        } touchViewConstructor:^(MBPageStatusTouchView *touchView) {
            if (!weakSelf) return;
            weakSelf.loadingTouchView = touchView;
            touchView.contentSize = weakSelf.containerSize;
            touchView.touchable = NO;
        }];
        
        _loadingDisplayItem.pageInformationDisplayDelegate = self;
    }
    return _loadingDisplayItem;
}

- (LFPageInformationDisplayItem *)noDataDisplayItem {
    if (!_noDataDisplayItem) {
        __weak typeof(self)weakSelf = self;
        _noDataDisplayItem = [self.class createDisplayItemWithContainerView:self.containerView statusViewConstructor:^(MBDataRequestStatusView *statusView) {
            if (!weakSelf) return;
            weakSelf.noDataStatusView = statusView;
            
            statusView.textLabel.attributedText = weakSelf.noDataTextGetter(weakSelf, weakSelf.noDataViewTouchable);
            
            NSArray *imgs = weakSelf.noDataImage?@[weakSelf.noDataImage]:nil;
            CGFloat imageViewHeight = [weakSelf.class statusView:statusView updateWithImages:imgs];
            
            MBDataRequestStatusViewLayout *layout = [[weakSelf.class defaultStatusViewLayout] copy];
            layout.width = weakSelf.containerSize.width;
            layout.imageViewHeight = imageViewHeight;
            layout.textLabelInsets = ({
                UIEdgeInsets inset = layout.textLabelInsets;
                inset.top = imageViewHeight==0?0:16;
                inset;
            });
            statusView.layout = layout;
            
            [weakSelf.class invalidateIntrinsicContentSizeForStatusView:statusView];
            
        } touchViewConstructor:^(MBPageStatusTouchView *touchView) {
            
            if (!weakSelf) return;
            weakSelf.noDataTouchView = touchView;
            touchView.contentSize = weakSelf.containerSize;
            
            // add tap gesture
            UIGestureRecognizer *touch = [[UITapGestureRecognizer alloc]initWithTarget:touchView
                                                                                action:@selector(executeTouchBlock)];
            [touchView addGestureRecognizer:touch];
            
            touchView.touchable = weakSelf.noDataViewTouchable;
            touchView.touchBlock = ^{
                if (weakSelf.noDataViewTouchBlock) weakSelf.noDataViewTouchBlock(weakSelf);
            };
            
        }];
    }
    return _noDataDisplayItem;
}

- (LFPageInformationDisplayItem *)noNetworkDisplayItem {
    if (!_noNetworkDisplayItem) {
        __weak typeof(self)weakSelf = self;
        _noNetworkDisplayItem = [self.class createDisplayItemWithContainerView:self.containerView statusViewConstructor:^(MBDataRequestStatusView *statusView) {
            if (!weakSelf) return;
            weakSelf.noNetworkStatusView = statusView;
            
            statusView.textLabel.attributedText = weakSelf.noDataTextGetter(weakSelf, weakSelf.noNetworkViewTouchable);
            
            NSArray *imgs = weakSelf.noNetworkImage?@[weakSelf.noNetworkImage]:nil;
            CGFloat imageViewHeight = [weakSelf.class statusView:statusView updateWithImages:imgs];
            
            MBDataRequestStatusViewLayout *layout = [[weakSelf.class defaultStatusViewLayout] copy];
            layout.width = weakSelf.containerSize.width;
            layout.imageViewHeight = imageViewHeight;
            layout.textLabelInsets = ({
                UIEdgeInsets inset = layout.textLabelInsets;
                inset.top = imageViewHeight==0?0:16;
                inset;
            });
            statusView.layout = layout;
            
            [weakSelf.class invalidateIntrinsicContentSizeForStatusView:statusView];
            
        } touchViewConstructor:^(MBPageStatusTouchView *touchView) {
            
            if (!weakSelf) return;
            weakSelf.noNetworkTouchView = touchView;
            touchView.contentSize = weakSelf.containerSize;
            
            // add tap gesture
            UIGestureRecognizer *touch = [[UITapGestureRecognizer alloc]initWithTarget:touchView
                                                                                action:@selector(executeTouchBlock)];
            [touchView addGestureRecognizer:touch];
            
            touchView.touchable = weakSelf.noNetworkViewTouchable;
            touchView.touchBlock = ^{
                if (weakSelf.noNetworkViewTouchBlock) weakSelf.noNetworkViewTouchBlock(weakSelf);
            };
            
        }];
    }
    return _noNetworkDisplayItem;
}

- (LFPageInformationDisplayItem *)normalErrorDisplayItem {
    if (!_normalErrorDisplayItem) {
        __weak typeof(self)weakSelf = self;
        _normalErrorDisplayItem = [self.class createDisplayItemWithContainerView:self.containerView statusViewConstructor:^(MBDataRequestStatusView *statusView) {
            if (!weakSelf) return;
            weakSelf.normalErrorStatusView = statusView;
            
            statusView.textLabel.attributedText = weakSelf.noDataTextGetter(weakSelf, weakSelf.normalErrorViewTouchable);
            
            NSArray *imgs = weakSelf.normalErrorImage?@[weakSelf.normalErrorImage]:nil;
            CGFloat imageViewHeight = [weakSelf.class statusView:statusView updateWithImages:imgs];
            
            MBDataRequestStatusViewLayout *layout = [[weakSelf.class defaultStatusViewLayout] copy];
            layout.width = weakSelf.containerSize.width;
            layout.imageViewHeight = imageViewHeight;
            layout.textLabelInsets = ({
                UIEdgeInsets inset = layout.textLabelInsets;
                inset.top = imageViewHeight==0?0:16;
                inset;
            });
            statusView.layout = layout;
            
            [weakSelf.class invalidateIntrinsicContentSizeForStatusView:statusView];
            
        } touchViewConstructor:^(MBPageStatusTouchView *touchView) {
            
            if (!weakSelf) return;
            weakSelf.normalErrorTouchView = touchView;
            touchView.contentSize = weakSelf.containerSize;
            
            // add tap gesture
            UIGestureRecognizer *touch = [[UITapGestureRecognizer alloc]initWithTarget:touchView
                                                                                action:@selector(executeTouchBlock)];
            [touchView addGestureRecognizer:touch];
            
            touchView.touchable = weakSelf.normalErrorViewTouchable;
            touchView.touchBlock = ^{
                if (weakSelf.normalErrorViewTouchBlock) weakSelf.normalErrorViewTouchBlock(weakSelf);
            };
            
        }];
    }
    return _normalErrorDisplayItem;
}

+ (void)invalidateIntrinsicContentSizeForStatusView:(MBDataRequestStatusView *)statusView {
    if (!statusView) return;
    
    [statusView invalidateIntrinsicContentSize];
    CGSize intrinsicSize = statusView.lfpi_intrinsicContentSize;
    [statusView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(intrinsicSize.width);
        make.height.mas_equalTo(intrinsicSize.height);
    }];
}


/**
 Update images of `statusView`, and get the height of image view after update images.

 @param statusView The status view
 @param images images to be updated
 @return the height of image view after update images
 */
+ (CGFloat)statusView:(MBDataRequestStatusView *)statusView updateWithImages:(NSArray<UIImage *> *)images {
    if (!statusView) return 0;
    if (images.count > 1) {
        statusView.imageView.image = nil;
        statusView.imageView.animationDuration = 0.12*images.count;
        statusView.imageView.animationImages = images;
    } else {
        statusView.imageView.animationImages = nil;
        statusView.imageView.image = images.firstObject;
    }
    
    
    
    CGFloat maxImgHeight = 0;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    for (UIImage *img in images) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    if (maxImgHeight < 0) maxImgHeight = 0;
    
    return maxImgHeight;
}

- (void)setContainerSize:(CGSize)containerSize {
    _containerSize = containerSize;
    
    _loadingTouchView.contentSize = containerSize;
    if (_loadingStatusView) {
        MBDataRequestStatusViewLayout *layout = _loadingStatusView.layout;
        layout.width = containerSize.width;
        _loadingStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_loadingStatusView];
    }
    
    _noDataTouchView.contentSize = containerSize;
    if (_noDataStatusView) {
        MBDataRequestStatusViewLayout *layout = _noDataStatusView.layout;
        layout.width = containerSize.width;
        _noDataStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_noDataStatusView];
    }
    
    _noNetworkTouchView.contentSize = containerSize;
    if (_noNetworkStatusView) {
        MBDataRequestStatusViewLayout *layout = _noNetworkStatusView.layout;
        layout.width = containerSize.width;
        _noNetworkStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_noNetworkStatusView];
    }
    
    _normalErrorTouchView.contentSize = containerSize;
    if (_normalErrorStatusView) {
        MBDataRequestStatusViewLayout *layout = _normalErrorStatusView.layout;
        layout.width = containerSize.width;
        _normalErrorStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_normalErrorStatusView];
    }
}

- (void)setLoadingText:(NSAttributedString *)loadingText {
    _loadingText = [loadingText copy];
    
    if (_loadingStatusView) {
        _loadingStatusView.textLabel.attributedText = loadingText;
        [self.class invalidateIntrinsicContentSizeForStatusView:_loadingStatusView];
    }
}

- (void)setLoadingImages:(NSArray<UIImage *> *)loadingImages {
    _loadingImages = [loadingImages copy];
    
    if (_loadingStatusView) {
        [_loadingStatusView.imageView stopAnimating];
        CGFloat imageViewHeight = [self.class statusView:_loadingStatusView updateWithImages:loadingImages];
        
        MBDataRequestStatusViewLayout *layout = _loadingStatusView.layout;
        layout.imageViewHeight = imageViewHeight;
        layout.textLabelInsets = ({
            UIEdgeInsets inset = layout.textLabelInsets;
            inset.top = imageViewHeight==0?0:16;
            inset;
        });
        
        _loadingStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_loadingStatusView];
    }
}

- (void)setNoDataTextGetter:(NSAttributedString *(^)(MBPageStatusKit *, BOOL))noDataTextGetter {
    _noDataTextGetter = [noDataTextGetter copy];
    
    if (_noDataStatusView) {
        if (noDataTextGetter) {
            _noDataStatusView.textLabel.attributedText = noDataTextGetter(self, self.noDataViewTouchable);
        } else {
            _noDataStatusView.textLabel.attributedText = nil;
        }
        [self.class invalidateIntrinsicContentSizeForStatusView:_noDataStatusView];
    }
}

- (void)setNoDataViewTouchable:(BOOL)noDataViewTouchable {
    _noDataViewTouchable = noDataViewTouchable;
    
    _noDataTouchView.touchable = noDataViewTouchable;
    
    if (self.noDataTextGetter) {
        _noDataStatusView.textLabel.attributedText = self.noDataTextGetter(self, noDataViewTouchable);
    } else {
        _noDataStatusView.textLabel.attributedText = nil;
    }
    [self.class invalidateIntrinsicContentSizeForStatusView:_noDataStatusView];
}

- (void)setNoDataImage:(UIImage *)noDataImage {
    _noDataImage = noDataImage;
    
    if (_noDataStatusView) {
        NSArray *imgs = noDataImage?@[noDataImage]:nil;
        CGFloat imageViewHeight = [self.class statusView:_noDataStatusView updateWithImages:imgs];
        
        MBDataRequestStatusViewLayout *layout = _noDataStatusView.layout;
        layout.imageViewHeight = imageViewHeight;
        layout.textLabelInsets = ({
            UIEdgeInsets inset = layout.textLabelInsets;
            inset.top = imageViewHeight==0?0:16;
            inset;
        });
        
        _noDataStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_noDataStatusView];
    }
}

- (void)setNoDataViewTouchBlock:(void (^)(MBPageStatusKit *))noDataViewTouchBlock {
    _noDataViewTouchBlock = [noDataViewTouchBlock copy];
    
    __weak typeof(self)weakSelf = self;
    _noDataTouchView.touchBlock = ^{
        if (weakSelf.noDataViewTouchBlock) weakSelf.noDataViewTouchBlock(weakSelf);
    };
}

- (void)setNoNetworkTextGetter:(NSAttributedString *(^)(MBPageStatusKit *, BOOL))noNetworkTextGetter {
    _noNetworkTextGetter = [noNetworkTextGetter copy];
    
    if (_noNetworkStatusView) {
        if (noNetworkTextGetter) {
            _noNetworkStatusView.textLabel.attributedText = noNetworkTextGetter(self, self.noNetworkViewTouchable);
        } else {
            _noNetworkStatusView.textLabel.attributedText = nil;
        }
        [self.class invalidateIntrinsicContentSizeForStatusView:_noNetworkStatusView];
    }
}

- (void)setNoNetworkViewTouchable:(BOOL)noNetworkViewTouchable {
    _noNetworkViewTouchable = noNetworkViewTouchable;
    
    _noNetworkTouchView.touchable = noNetworkViewTouchable;
    
    if (self.noNetworkTextGetter) {
        _noNetworkStatusView.textLabel.attributedText = self.noNetworkTextGetter(self, noNetworkViewTouchable);
    } else {
        _noNetworkStatusView.textLabel.attributedText = nil;
    }
    [self.class invalidateIntrinsicContentSizeForStatusView:_noNetworkStatusView];
}

- (void)setNoNetworkImage:(UIImage *)noNetworkImage {
    _noNetworkImage = noNetworkImage;
    
    if (_noNetworkStatusView) {
        NSArray *imgs = noNetworkImage?@[noNetworkImage]:nil;
        CGFloat imageViewHeight = [self.class statusView:_noNetworkStatusView updateWithImages:imgs];
        
        MBDataRequestStatusViewLayout *layout = _noNetworkStatusView.layout;
        layout.imageViewHeight = imageViewHeight;
        layout.textLabelInsets = ({
            UIEdgeInsets inset = layout.textLabelInsets;
            inset.top = imageViewHeight==0?0:16;
            inset;
        });
        
        _noNetworkStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_noNetworkStatusView];
    }
}

- (void)setNoNetworkViewTouchBlock:(void (^)(MBPageStatusKit *))noNetworkViewTouchBlock {
    _noNetworkViewTouchBlock = [noNetworkViewTouchBlock copy];
    
    __weak typeof(self)weakSelf = self;
    _noNetworkTouchView.touchBlock = ^{
        if (weakSelf.noNetworkViewTouchBlock) weakSelf.noNetworkViewTouchBlock(weakSelf);
    };
}

- (void)setNormalErrorTextGetter:(NSAttributedString *(^)(MBPageStatusKit *, BOOL))normalErrorTextGetter {
    _normalErrorTextGetter = [normalErrorTextGetter copy];
    
    if (_normalErrorStatusView) {
        if (normalErrorTextGetter) {
            _normalErrorStatusView.textLabel.attributedText = normalErrorTextGetter(self, self.normalErrorViewTouchable);
        } else {
            _normalErrorStatusView.textLabel.attributedText = nil;
        }
        [self.class invalidateIntrinsicContentSizeForStatusView:_normalErrorStatusView];
    }
}

- (void)setNormalErrorViewTouchable:(BOOL)normalErrorViewTouchable {
    _normalErrorViewTouchable = normalErrorViewTouchable;
    
    _normalErrorTouchView.touchable = normalErrorViewTouchable;
    
    if (self.normalErrorTextGetter) {
        _normalErrorStatusView.textLabel.attributedText = self.normalErrorTextGetter(self, normalErrorViewTouchable);
    } else {
        _normalErrorStatusView.textLabel.attributedText = nil;
    }
    [self.class invalidateIntrinsicContentSizeForStatusView:_normalErrorStatusView];
}

- (void)setNormalErrorImage:(UIImage *)normalErrorImage {
    _normalErrorImage = normalErrorImage;
    
    if (_normalErrorStatusView) {
        NSArray *imgs = normalErrorImage?@[normalErrorImage]:nil;
        CGFloat imageViewHeight = [self.class statusView:_normalErrorStatusView updateWithImages:imgs];
        
        MBDataRequestStatusViewLayout *layout = _normalErrorStatusView.layout;
        layout.imageViewHeight = imageViewHeight;
        layout.textLabelInsets = ({
            UIEdgeInsets inset = layout.textLabelInsets;
            inset.top = imageViewHeight==0?0:16;
            inset;
        });
        
        _normalErrorStatusView.layout = layout;
        [self.class invalidateIntrinsicContentSizeForStatusView:_normalErrorStatusView];
    }
}

- (void)setNormalErrorViewTouchBlock:(void (^)(MBPageStatusKit *))normalErrorViewTouchBlock {
    _normalErrorViewTouchBlock = [normalErrorViewTouchBlock copy];
    
    __weak typeof(self)weakSelf = self;
    _normalErrorTouchView.touchBlock = ^{
        if (weakSelf.normalErrorViewTouchBlock) weakSelf.normalErrorViewTouchBlock(weakSelf);
    };
}

- (void)showLoading {
    [self hideAllBut:self.loadingDisplayItem];
    [self.loadingDisplayItem displayWithAnimated:NO];
}

- (void)showNoData {
    [self hideAllBut:self.noDataDisplayItem];
    [self.noDataDisplayItem displayWithAnimated:NO];
}

- (void)showNoNetwork {
    [self hideAllBut:self.noNetworkDisplayItem];
    [self.noNetworkDisplayItem displayWithAnimated:NO];
}

- (void)showNormalError {
    [self hideAllBut:self.normalErrorDisplayItem];
    [self.normalErrorDisplayItem displayWithAnimated:NO];
}

- (void)hide {
    [self hideAllBut:nil];
}

+ (NSAttributedString *)createAttributedTextWithText:(NSString *)text
                                                font:(UIFont *)font
                                           textColor:(UIColor *)textColor {
    if (!text) return nil;
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    if (font) attrs[NSFontAttributeName] = font;
    if (textColor) attrs[NSForegroundColorAttributeName] = textColor;
    return [[NSAttributedString alloc] initWithString:text attributes:attrs];
}

#pragma mark - LFPageInformationDisplayItemDelegate

- (void)lfpi_informationViewDidDisplay:(LFPageInformationDisplayItem *)displayItem
{
    if (displayItem == _loadingDisplayItem && _loadingStatusView) {
        [_loadingStatusView.imageView startAnimating];
    }
}

- (void)lfpi_informationViewDidHide:(LFPageInformationDisplayItem *)displayItem
{
    if (displayItem == _loadingDisplayItem && _loadingStatusView) {
        [_loadingStatusView.imageView stopAnimating];
    }
}

@end
