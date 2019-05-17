//
//  MBRefreshKit.m
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBRefreshKit.h"
#import "MBDataRequestStatusView.h"
#import "BOOLRefreshController.h"
#import "Masonry.h"
#import "NSObject+TDKit.h"

@interface MBDataRequestStatusView (MBRefreshKit) <BOOLRefreshControlProtocol>

@property (nonatomic, copy) NSAttributedString *idleStateText;
@property (nonatomic, copy) NSAttributedString *refreshableStateText;
@property (nonatomic, copy) NSAttributedString *refreshingStateText;

@property (nonatomic, copy) NSArray<UIImage *> *idleStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *refreshableStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *refreshingStateImages;

@end

@implementation MBDataRequestStatusView (MBRefreshKit)
@dynamic idleStateText;
@dynamic refreshableStateText;
@dynamic refreshingStateText;

@dynamic idleStateImages;
@dynamic refreshableStateImages;
@dynamic refreshingStateImages;

- (void)setIdleStateText:(NSAttributedString *)idleStateText {
    [self setAssociateValue:[idleStateText copy] withKey:@"idleStateText"];
}

- (NSAttributedString *)idleStateText {
    return [self getAssociatedValueForKey:@"idleStateText"];
}

- (void)setRefreshableStateText:(NSAttributedString *)refreshableStateText {
    [self setAssociateValue:[refreshableStateText copy] withKey:@"refreshableStateText"];
}

- (NSAttributedString *)refreshableStateText {
    return [self getAssociatedValueForKey:@"refreshableStateText"];
}

- (void)setRefreshingStateText:(NSAttributedString *)refreshingStateText {
    [self setAssociateValue:[refreshingStateText copy] withKey:@"refreshingStateText"];
}

- (NSAttributedString *)refreshingStateText {
    return [self getAssociatedValueForKey:@"refreshingStateText"];
}

- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages {
    [self setAssociateValue:[idleStateImages copy] withKey:@"idleStateImages"];
}

- (NSArray<UIImage *> *)idleStateImages {
    return [self getAssociatedValueForKey:@"idleStateImages"];
}

- (void)setRefreshableStateImages:(NSArray<UIImage *> *)refreshableStateImages {
    [self setAssociateValue:[refreshableStateImages copy] withKey:@"refreshableStateImages"];
}

- (NSArray<UIImage *> *)refreshableStateImages {
    return [self getAssociatedValueForKey:@"refreshableStateImages"];
}

- (void)setRefreshingStateImages:(NSArray<UIImage *> *)refreshingStateImages {
    [self setAssociateValue:[refreshingStateImages copy] withKey:@"refreshingStateImages"];
}

- (NSArray<UIImage *> *)refreshingStateImages {
    return [self getAssociatedValueForKey:@"refreshingStateImages"];
}


#pragma mark - BOOLRefreshControlProtocol

- (void)stateWillChangeFromCurrent:(BOOLRefreshControlState)fromCurrentState
                           toState:(BOOLRefreshControlState)toState {

}

- (void)stateDidChangedFromOld:(BOOLRefreshControlState)fromOldState
                toCurrentState:(BOOLRefreshControlState)toCurrentState {
    
    NSAttributedString *stateText = nil;
    NSArray<UIImage *> *stateImages = nil;
    if (toCurrentState == BOOLRefreshControlStateIdle) {
        stateText = self.idleStateText;
        stateImages = self.idleStateImages;
    } else if (toCurrentState == BOOLRefreshControlPulling) {
        stateText = self.refreshableStateText;
        stateImages = self.refreshableStateImages;
    } else if (toCurrentState == BOOLRefreshControlRefreshing) {
        stateText = self.refreshingStateText;
        stateImages = self.refreshingStateImages;
    }
    
    self.textLabel.attributedText = stateText;
    
    if (toCurrentState != BOOLRefreshControlStateIdle && stateImages.count > 0) {
        [self.imageView stopAnimating];
        self.imageView.animationDuration = (0.12 * stateImages.count);
        self.imageView.animationImages = stateImages;
        [self.imageView startAnimating];
    } else {
        [self.imageView stopAnimating];
    }
}

- (void)animateWhenFinishRefresh {
    
}

- (void)pullingPercentChangeTo:(CGFloat)pullingPercent {
        
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

static NSString *const MBRefreshKitKeyPathBounds = @"MBRefreshKitKeyPathBounds";

@interface MBRefreshKit ()

@property (nonatomic, copy) void(^refreshBlock)(MBRefreshKit *kit);

@property (nonatomic, strong) MBDataRequestStatusView *statusView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOLRefreshController *refreshController;

@property (nonatomic, copy) NSAttributedString *idleStateText;
@property (nonatomic, copy) NSAttributedString *refreshableStateText;
@property (nonatomic, copy) NSAttributedString *refreshingStateText;
@property (nonatomic, copy) NSArray<UIImage *> *idleStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *refreshableStateImages;
@property (nonatomic, copy) NSArray<UIImage *> *refreshingStateImages;

@end

@implementation MBRefreshKit

- (instancetype)initWithRefreshBlock:(void(^)(MBRefreshKit *kit))refreshBlock {
    if (self = [super init]) {
        self.refreshBlock = refreshBlock;
    }
    return self;
}

- (void)dealloc {
    [self uninstall];
}

- (NSAttributedString *)stateTextOfMaxHeightWithConstraintWidth:(CGFloat)constraintWidth {
    CGFloat idleTextHeight = [self.idleStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat refreshableTextHeight = [self.refreshableStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat refreshingTextHeight = [self.refreshingStateText boundingRectWithSize:CGSizeMake(constraintWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    
    NSAttributedString *stateText = self.idleStateText;
    CGFloat maxHeight = idleTextHeight;
    if (maxHeight < refreshableTextHeight) {
        stateText = self.refreshableStateText;
        maxHeight = refreshableTextHeight;
    }
    if (maxHeight < refreshingTextHeight) {
        stateText = self.refreshingStateText;
        maxHeight = refreshingTextHeight;
    }
    
    return stateText;
}

- (CGFloat)maxHeightOfStateImages {
    CGFloat maxImgHeight = 0;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    for (UIImage *img in self.idleStateImages) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    for (UIImage *img in self.refreshableStateImages) {
        maxImgHeight = MAX(maxImgHeight, (img.size.height*img.scale)/screenScale);
    }
    for (UIImage *img in self.refreshingStateImages) {
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

- (void)addScrollViewBoundsObserver {
    [self.scrollView addObserver:self
                      forKeyPath:MBRefreshKitKeyPathBounds
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

- (void)removeScrollViewBoundsObserver {
    @try {
        [self.scrollView removeObserver:self forKeyPath:MBRefreshKitKeyPathBounds context:nil];
    } @catch (id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:MBRefreshKitKeyPathBounds]) {
        [self updateStatusViewLayout];
        self.refreshController.refreshThreshold = [_statusView intrinsicContentSize].height;
    }
}

- (void)setIdleStateText:(NSAttributedString *)idleStateText
    refreshableStateText:(NSAttributedString *)refreshableStateText
     refreshingStateText:(NSAttributedString *)refreshingStateText {
    
    self.idleStateText = idleStateText;
    self.refreshableStateText = refreshableStateText;
    self.refreshingStateText = refreshingStateText;
    
    if (_statusView) {
        [_statusView setIdleStateText:idleStateText];
        [_statusView setRefreshableStateText:refreshableStateText];
        [_statusView setRefreshingStateText:refreshingStateText];
        
        [self updateStatusViewLayout];
        self.refreshController.refreshThreshold = [_statusView intrinsicContentSize].height;
    }
}

- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages
    refreshableStateImages:(NSArray<UIImage *> *)refreshableStateImages
     refreshingStateImages:(NSArray<UIImage *> *)refreshingStateImages {
    
    self.idleStateImages = idleStateImages;
    self.refreshableStateImages = refreshableStateImages;
    self.refreshingStateImages = refreshingStateImages;
    
    if (_statusView) {
        [_statusView setIdleStateImages:idleStateImages];
        [_statusView setRefreshableStateImages:refreshableStateImages];
        [_statusView setRefreshingStateImages:refreshingStateImages];
        
        [self updateStatusViewLayout];
        self.refreshController.refreshThreshold = [_statusView intrinsicContentSize].height;
    }
}

- (BOOL)isRefreshing {
    return (_refreshController.state == BOOLRefreshControlRefreshing);
}

- (void)installToScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    
    {
        // configure statusView
        __weak typeof(self)weakSelf = self;
        [_statusView removeFromSuperview];
        _statusView = nil;
        
        self.statusView = [[MBDataRequestStatusView alloc] init];
        
        self.statusView.idleStateText = self.idleStateText;
        self.statusView.refreshableStateText = self.refreshableStateText;
        self.statusView.refreshingStateText = self.refreshingStateText;
        
        self.statusView.idleStateImages = self.idleStateImages;
        self.statusView.refreshableStateImages = self.refreshableStateImages;
        self.statusView.refreshingStateImages = self.refreshingStateImages;
        
        
        [self updateStatusViewLayout];
        
        [self.scrollView addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.bottom.equalTo(weakSelf.scrollView.mas_top);
        }];
    }
    
    {
        __weak typeof(self)weakSelf = self;
        // configure refreshController
        self.refreshController = [[BOOLRefreshController alloc] initWithObservable:scrollView];
        
        self.refreshController.refreshThreshold = [self.statusView intrinsicContentSize].height;
        
        self.refreshController.stateWillChangeBlock = ^(BOOLRefreshController *controller, BOOLRefreshControlState current, BOOLRefreshControlState willState) {
            if ([weakSelf.statusView respondsToSelector:@selector(stateWillChangeFromCurrent:toState:)]) {
                [weakSelf.statusView stateWillChangeFromCurrent:current toState:willState];
            }
        };
        
        self.refreshController.stateDidChangedBlock = ^(BOOLRefreshController *controller, BOOLRefreshControlState old, BOOLRefreshControlState currentState) {
            
            if ([weakSelf.statusView respondsToSelector:@selector(stateDidChangedFromOld:toCurrentState:)]) {
                [weakSelf.statusView stateDidChangedFromOld:old toCurrentState:currentState];
            }
        };
        
        self.refreshController.pullingPercentChangeBlock = ^(BOOLRefreshController *refreshController, CGFloat pullingPercent){
            if ([weakSelf.statusView respondsToSelector:@selector(pullingPercentChangeTo:)]) {
                [weakSelf.statusView pullingPercentChangeTo:pullingPercent];
            }
        };
        
        _refreshController.finishRefreshAnimationBlock = ^(BOOLRefreshController *controller){
            if ([weakSelf.statusView respondsToSelector:@selector(animateWhenFinishRefresh)]) {
                [weakSelf.statusView animateWhenFinishRefresh];
            }
        };
        
        self.refreshController.refreshExecuteBlock = ^(BOOLRefreshController *controller){
            if (weakSelf.refreshBlock) {
                weakSelf.refreshBlock(weakSelf);
            }
        };
    }
    
    [self addScrollViewBoundsObserver];
}

- (void)uninstall {
    [self removeScrollViewBoundsObserver];
    [_statusView removeFromSuperview];
    _statusView = nil;
    _refreshController = nil;
}

- (void)finishRefreshing {
    [_refreshController finishRefreshing];
}

@end
