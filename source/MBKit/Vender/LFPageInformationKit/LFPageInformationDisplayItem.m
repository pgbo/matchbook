//
//  LFPageInformationDisplayItem.m
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import "LFPageInformationDisplayItem.h"

@interface LFPageInformationDisplayAnimationContext : NSObject <LFPageInformationContextAnimationing>

@property (nonatomic) UIView * lfpi_containerView;

@property (nonatomic, assign) BOOL lfpi_fromVisible;

@property (nonatomic, assign) BOOL lfpi_toVisible;

@property (nonatomic, copy) void(^lfpi_completeAnimationBlock)(BOOL didComplete);

@end

@implementation LFPageInformationDisplayAnimationContext

@end

@interface LFPageInformationDisplayItem ()

@property (nonatomic, assign) BOOL isDisplaying;

@end

@implementation LFPageInformationDisplayItem

- (instancetype)initWithPageInformationDisplayView:(UIView<LFPageInformationDisplayView> *)pageInformationDisplayView
                      pageInformationContainerView:(UIView *)pageInformationContainerView
{
    NSAssert(pageInformationDisplayView != nil, @"pageInformationDisplayView can't be nil");
    NSAssert(pageInformationContainerView != nil, @"pageInformationContainerView can't be nil");
    if (self = [super init]) {
        _pageInformationDisplayView = pageInformationDisplayView;
        _pageInformationContainerView = pageInformationContainerView;
        [self layoutIfNeed];
    }
    return self;
}

- (void)layoutIfNeed
{
    if (_pageInformationDisplayView.superview != _pageInformationContainerView) {
        [_pageInformationDisplayView removeFromSuperview];
        if (_pageInformationDisplayView.lfpi_hideBeforeAddIntoContainerView) {
            _pageInformationDisplayView.hidden = YES;
        }
        [_pageInformationContainerView addSubview:_pageInformationDisplayView];
    }
    
    CGRect pageInformationDisplayBounds = _pageInformationDisplayView.bounds;
    CGSize pageInformationIntrinsicContentSize = _pageInformationDisplayView.lfpi_intrinsicContentSize;
    if (!CGSizeEqualToSize(pageInformationDisplayBounds.size, pageInformationIntrinsicContentSize)) {
        _pageInformationDisplayView.bounds = CGRectMake(CGRectGetMinX(pageInformationDisplayBounds),
                                                        CGRectGetMinY(pageInformationDisplayBounds),
                                                        pageInformationIntrinsicContentSize.width,
                                                        pageInformationIntrinsicContentSize.height);
    }
    
    if (_pageInformationDisplayView.lfpi_aliginCenter) {
        CGRect containnerBounds = _pageInformationContainerView.bounds;
        _pageInformationDisplayView.center = CGPointMake(CGRectGetMidX(containnerBounds), CGRectGetMidY(containnerBounds));
    }
}

- (void)displayWithAnimated:(BOOL)animated
{
    if (_isDisplaying) {
        return;
    }
    
    [self layoutIfNeed];
    _pageInformationDisplayView.hidden = NO;
    [_pageInformationContainerView bringSubviewToFront:_pageInformationDisplayView];
    
    
    if (animated && self.pageInformationAnimation) {
        
        _isDisplaying = YES;
        
        LFPageInformationDisplayAnimationContext *animationCtx = [[LFPageInformationDisplayAnimationContext alloc]init];
        animationCtx.lfpi_containerView = _pageInformationContainerView;
        animationCtx.lfpi_fromVisible = NO;
        animationCtx.lfpi_toVisible = YES;
        animationCtx.lfpi_completeAnimationBlock = ^(BOOL didComplete){
            [self didShow];
        };
        [self.pageInformationAnimation lfpi_animate:animationCtx];
        
    } else {
        _isDisplaying = YES;
        [self didShow];
    }
}

- (void)didShow
{
    if (self.pageInformationDisplayDelegate
        && [self.pageInformationDisplayDelegate respondsToSelector:@selector(lfpi_informationViewDidDisplay:)]) {
        [self.pageInformationDisplayDelegate lfpi_informationViewDidDisplay:self];
    }
}

- (void)hideWithAnimated:(BOOL)animated
{
    if (!_isDisplaying) {
        return;
    }
    
    if (_pageInformationDisplayView.superview != _pageInformationContainerView) {
        return;
    }
    
    if (animated && self.pageInformationAnimation) {
        
        _isDisplaying = NO;
        
        LFPageInformationDisplayAnimationContext *animationCtx = [[LFPageInformationDisplayAnimationContext alloc]init];
        animationCtx.lfpi_containerView = _pageInformationContainerView;
        animationCtx.lfpi_fromVisible = YES;
        animationCtx.lfpi_toVisible = NO;
        animationCtx.lfpi_completeAnimationBlock = ^(BOOL didComplete){
            [self didHide];
        };
        [self.pageInformationAnimation lfpi_animate:animationCtx];
        
    } else {
        _isDisplaying = NO;
        [self didHide];
    }
}

- (void)didHide
{
    if (_pageInformationDisplayView.lfpi_removeFromSuperViewWhenHide) {
        [_pageInformationDisplayView removeFromSuperview];
    }
    
    if (self.pageInformationDisplayDelegate
        && [self.pageInformationDisplayDelegate respondsToSelector:@selector(lfpi_informationViewDidHide:)]) {
        [self.pageInformationDisplayDelegate lfpi_informationViewDidHide:self];
    }
}

@end
