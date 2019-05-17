//
//  MBLoadMoreKit.m
//  matchbook
//
//  Created by guangbool on 2017/7/6.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBLoadMoreKit.h"
#import "BOOLoadMoreController.h"
#import "MBDataRequestStatusView.h"
#import "Masonry.h"
#import "NSObject+TDKit.h"

@interface MBDataRequestStatusView (MBLoadMoreKit)

@property (nonatomic, copy) NSAttributedString *idleStateText;
@property (nonatomic, copy) NSAttributedString *loadableStateText;
@property (nonatomic, copy) NSAttributedString *loadingStateText;

@property (nonatomic, copy) NSArray<UIImage *> *idleStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *loadableStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *loadingStateImages;

- (void)loadMoreStateWillChangeFromCurrent:(BOOLoadMoreControlState)fromCurrentState
                                   toState:(BOOLoadMoreControlState)toState;
- (void)loadMoreStateDidChangedFromOld:(BOOLoadMoreControlState)fromOldState
                        toCurrentState:(BOOLoadMoreControlState)toCurrentState;
- (void)loadMoreAnimateWhenFinishRefresh;
- (void)loadMorePullingPercentChangeTo:(CGFloat)pullingPercent;

@end

@implementation MBDataRequestStatusView (MBLoadMoreKit)
@dynamic idleStateText;
@dynamic loadableStateText;
@dynamic loadingStateText;

@dynamic idleStateImages;
@dynamic loadableStateImages;
@dynamic loadingStateImages;

- (void)setIdleStateText:(NSAttributedString *)idleStateText {
    [self setAssociateValue:[idleStateText copy] withKey:@"idleStateText"];
}

- (NSAttributedString *)idleStateText {
    return [self getAssociatedValueForKey:@"idleStateText"];
}

- (void)setLoadableStateText:(NSAttributedString *)loadableStateText {
    [self setAssociateValue:[loadableStateText copy] withKey:@"loadableStateText"];
}

- (NSAttributedString *)loadableStateText {
    return [self getAssociatedValueForKey:@"loadableStateText"];
}

- (void)setLoadingStateText:(NSAttributedString *)loadingStateText {
    [self setAssociateValue:[loadingStateText copy] withKey:@"loadingStateText"];
}

- (NSAttributedString *)loadingStateText {
    return [self getAssociatedValueForKey:@"loadingStateText"];
}

- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages {
    [self setAssociateValue:[idleStateImages copy] withKey:@"idleStateImages"];
}

- (NSArray<UIImage *> *)idleStateImages {
    return [self getAssociatedValueForKey:@"idleStateImages"];
}

- (void)setLoadableStateImages:(NSArray<UIImage *> *)loadableStateImages {
    [self setAssociateValue:[loadableStateImages copy] withKey:@"loadableStateImages"];
}

- (NSArray<UIImage *> *)loadableStateImages {
    return [self getAssociatedValueForKey:@"loadableStateImages"];
}

- (void)setLoadingStateImages:(NSArray<UIImage *> *)loadingStateImages {
    [self setAssociateValue:[loadingStateImages copy] withKey:@"loadingStateImages"];
}

- (NSArray<UIImage *> *)loadingStateImages {
    return [self getAssociatedValueForKey:@"loadingStateImages"];
}


#pragma mark - BOOLoadMoreControlProtocol

- (void)loadMoreStateWillChangeFromCurrent:(BOOLoadMoreControlState)fromCurrentState toState:(BOOLoadMoreControlState)toState {
    
}

- (void)loadMoreStateDidChangedFromOld:(BOOLoadMoreControlState)fromOldState toCurrentState:(BOOLoadMoreControlState)toCurrentState {
    
    NSAttributedString *stateText = nil;
    NSArray<UIImage *> *stateImages = nil;
    if (toCurrentState == BOOLoadMoreControlStateIdle) {
        stateText = self.idleStateText;
        stateImages = self.idleStateImages;
    } else if (toCurrentState == BOOLoadMoreControlPulling) {
        stateText = self.loadableStateText;
        stateImages = self.loadableStateImages;
    } else if (toCurrentState == BOOLoadMoreControlLoading) {
        stateText = self.loadingStateText;
        stateImages = self.loadingStateImages;
    }
    
    self.textLabel.attributedText = stateText;
    
    if (toCurrentState != BOOLoadMoreControlStateIdle && stateImages.count > 0) {
        [self.imageView stopAnimating];
        self.imageView.animationDuration = (0.12 * stateImages.count);
        self.imageView.animationImages = stateImages;
        [self.imageView startAnimating];
    } else {
        [self.imageView stopAnimating];
    }
}

- (void)loadMoreAnimateWhenFinishRefresh  {
    
}

- (void)loadMorePullingPercentChangeTo:(CGFloat)pullingPercent {
    //NSLog(@"pullingPercent: %@", @(pullingPercent));
    
    NSArray *pullingImages = [self idleStateImages];
    NSUInteger imagesCount = pullingImages.count;
    if (imagesCount <= 0) return;
    
    // 停止动画
    [self.imageView stopAnimating];
    
    // 设置当前需要显示的图片
    NSUInteger index =  imagesCount * pullingPercent;
    if (index >= imagesCount) index = imagesCount - 1;
    self.imageView.image = pullingImages[index];
}

@end


static NSString *const MBLoadMoreKitKeyPathBounds = @"MBLoadMoreKitKeyPathBounds";

@interface MBLoadMoreKit ()

@property (nonatomic, copy) void(^loadBlock)(MBLoadMoreKit *kit);

@property (nonatomic, strong) MBDataRequestStatusView *statusView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOLoadMoreController *loadMoreController;

@property (nonatomic, copy) NSAttributedString *idleStateText;
@property (nonatomic, copy) NSAttributedString *loadableStateText;
@property (nonatomic, copy) NSAttributedString *loadingStateText;
@property (nonatomic, copy) NSArray<UIImage *> *idleStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *loadableStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *loadingStateImages;

@end

@implementation MBLoadMoreKit

- (instancetype)initWithLoadBlock:(void(^)(MBLoadMoreKit *kit))loadBlock {
    if (self = [super init]) {
        self.loadBlock = loadBlock;
    }
    return self;
}

- (void)dealloc {
    [self uninstall];
}

- (NSAttributedString *)stateTextOfMaxHeightWithConstraintWidth:(CGFloat)constraintWidth {
    CGFloat idleTextHeight = [self.idleStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat loadableTextHeight = [self.loadableStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat loadingTextHeight = [self.loadingStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    
    NSAttributedString *stateText = self.idleStateText;
    CGFloat maxHeight = idleTextHeight;
    if (maxHeight < loadableTextHeight) {
        stateText = self.loadableStateText;
        maxHeight = loadableTextHeight;
    }
    if (maxHeight < loadingTextHeight) {
        stateText = self.loadingStateText;
        maxHeight = loadingTextHeight;
    }
    
    return stateText;
}

- (CGFloat)maxHeightOfStateImages {
    CGFloat maxImgHeight = 0;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    for (UIImage *img in self.idleStateImages) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    for (UIImage *img in self.loadableStateImages) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    for (UIImage *img in self.loadingStateImages) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    if (maxImgHeight < 0) maxImgHeight = 0;
    return maxImgHeight;
}

- (void)updateStatusViewLayout {
    
    CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
    
    NSAttributedString *maxHeightStateText = [self stateTextOfMaxHeightWithConstraintWidth:scrollViewWidth];
    self.statusView.textLabel.attributedText = maxHeightStateText;
    
    CGFloat maxImgHeight = [self maxHeightOfStateImages];
    
    MBDataRequestStatusViewLayout *layout = [MBDataRequestStatusViewLayout new];
    layout.width = scrollViewWidth;
    
    layout.imageViewHeight = maxImgHeight;
    
    UIEdgeInsets imageInset = UIEdgeInsetsMake(0, 16, 0, 16);
    imageInset.top = maxImgHeight>0?12:0;
    imageInset.bottom = maxImgHeight>0?12:0;
    
    UIEdgeInsets textInset = UIEdgeInsetsMake(0, 16, 0, 16);
    textInset.top = MAX(((maxHeightStateText.length>0?12:0) - imageInset.bottom), 0);
    textInset.bottom = maxHeightStateText.length>0?12:0;
    
    layout.imageViewInsets = imageInset;
    layout.textLabelInsets = textInset;
    
    self.statusView.layout = layout;
}

- (void)updateLoadMoreControllerLoadThreshold {
    CGFloat threshold = self.autoLoadWhenScrollToBottom?0:[_statusView intrinsicContentSize].height;
    _loadMoreController.loadThreshold = threshold;
}

- (void)addScrollViewBoundsObserver {
    [self.scrollView addObserver:self
                      forKeyPath:MBLoadMoreKitKeyPathBounds
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

- (void)removeScrollViewBoundsObserver {
    @try {
        [self.scrollView removeObserver:self forKeyPath:MBLoadMoreKitKeyPathBounds context:nil];
    } @catch (id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:MBLoadMoreKitKeyPathBounds]) {
        [self updateStatusViewLayout];
        [self updateLoadMoreControllerLoadThreshold];
    }
}

- (void)setAutoLoadWhenScrollToBottom:(BOOL)autoLoadWhenScrollToBottom {
    _autoLoadWhenScrollToBottom = autoLoadWhenScrollToBottom;
    
    [self updateLoadMoreControllerLoadThreshold];
}

- (void)setIdleStateText:(NSAttributedString *)idleStateText
       loadableStateText:(NSAttributedString *)loadableStateText
        loadingStateText:(NSAttributedString *)loadingStateText {
    
    self.idleStateText = idleStateText;
    self.loadableStateText = loadableStateText;
    self.loadingStateText = loadingStateText;
    
    if (_statusView) {
        [_statusView setIdleStateText:idleStateText];
        [_statusView setLoadableStateText:loadableStateText];
        [_statusView setLoadingStateText:loadingStateText];
        
        [self updateStatusViewLayout];
        [self updateLoadMoreControllerLoadThreshold];
    }
}

- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages
       loadableStateImages:(NSArray<UIImage *> *)loadableStateImages
        loadingStateImages:(NSArray<UIImage *> *)loadingStateImages {
    
    self.idleStateImages = idleStateImages;
    self.loadableStateImages = loadableStateImages;
    self.loadingStateImages = loadingStateImages;
    
    if (_statusView) {
        [_statusView setIdleStateImages:idleStateImages];
        [_statusView setLoadableStateImages:loadableStateImages];
        [_statusView setLoadingStateImages:loadingStateImages];
        
        [self updateStatusViewLayout];
        [self updateLoadMoreControllerLoadThreshold];
    }
}

- (BOOL)isLoading {
    return (_loadMoreController.state == BOOLoadMoreControlLoading);
}

- (void)installToScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    
    {
        // configure statusView
        [_statusView removeFromSuperview];
        _statusView = nil;
        
        self.statusView = [[MBDataRequestStatusView alloc] init];
        
        self.statusView.idleStateText = self.idleStateText;
        self.statusView.loadableStateText = self.loadableStateText;
        self.statusView.loadingStateText = self.loadingStateText;
        
        self.statusView.idleStateImages = self.idleStateImages;
        self.statusView.loadableStateImages = self.loadableStateImages;
        self.statusView.loadingStateImages = self.loadingStateImages;
        
        
        [self updateStatusViewLayout];
        
        [self.scrollView addSubview:self.statusView];
    }
    
    {
        __weak typeof(self)weakSelf = self;
        // configure refreshController
        self.loadMoreController = [[BOOLoadMoreController alloc] initWithObservable:scrollView];
        
        CGFloat statusViewHeight = [self.statusView intrinsicContentSize].height;
        self.loadMoreController.loadThreshold = self.autoLoadWhenScrollToBottom?0:statusViewHeight;
        self.loadMoreController.extraBottomInsetWhenLoading = statusViewHeight;
        
        self.loadMoreController.stateWillChangeBlock = ^(BOOLoadMoreController *controller, BOOLoadMoreControlState current, BOOLoadMoreControlState willState) {
            if ([weakSelf.statusView respondsToSelector:@selector(loadMoreStateWillChangeFromCurrent:toState:)]) {
                [weakSelf.statusView loadMoreStateWillChangeFromCurrent:current toState:willState];
            }
        };
        
        self.loadMoreController.stateDidChangedBlock = ^(BOOLoadMoreController *controller, BOOLoadMoreControlState old, BOOLoadMoreControlState currentState) {
            if ([weakSelf.statusView respondsToSelector:@selector(loadMoreStateDidChangedFromOld:toCurrentState:)]) {
                [weakSelf.statusView loadMoreStateDidChangedFromOld:old toCurrentState:currentState];
            }
        };
        
        self.loadMoreController.finishLoadAnimationBlock = ^(BOOLoadMoreController *controller) {
            if ([weakSelf.statusView respondsToSelector:@selector(loadMoreAnimateWhenFinishRefresh)]) {
                [weakSelf.statusView loadMoreAnimateWhenFinishRefresh];
            }
        };
        
        self.loadMoreController.pullingPercentChangeBlock = ^(BOOLoadMoreController *controller, CGFloat pullingPercent) {
            if ([weakSelf.statusView respondsToSelector:@selector(loadMorePullingPercentChangeTo:)]) {
                [weakSelf.statusView loadMorePullingPercentChangeTo:pullingPercent];
            }
        };
        
        self.loadMoreController.loadMoreExecuteBlock = ^(BOOLoadMoreController *controller){
            if (weakSelf.loadBlock) {
                weakSelf.loadBlock(weakSelf);
            }
        };
        
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.top.mas_equalTo(weakSelf.loadMoreController.scrollViewVisiableAreaMaxY);
        }];
        
        self.loadMoreController.scrollContentSizeChangedBlock = ^(BOOLoadMoreController *controller){
            if (controller.state == BOOLoadMoreControlStateIdle) {
                [weakSelf.statusView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(0);
                    make.top.mas_equalTo(controller.scrollViewVisiableAreaMaxY);
                }];
            }
        };
    }
    
    [self addScrollViewBoundsObserver];
}

- (void)uninstall {
    [self removeScrollViewBoundsObserver];
    [_statusView removeFromSuperview];
    _statusView = nil;
    _loadMoreController = nil;
}

- (void)finishLoading {
    [_loadMoreController finishLoadingWithDelay:0];
}

@end
