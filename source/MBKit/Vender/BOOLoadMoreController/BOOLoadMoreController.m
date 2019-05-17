//
//  BOOLoadMoreController.m
//  Sample
//
//  Created by guangbool on 2017/4/24.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "BOOLoadMoreController.h"

NSString *const BOOLoadMoreControllerKeyPathContentOffset = @"contentOffset";
NSString *const BOOLoadMoreControllerKeyPathContentSize = @"contentSize";
const NSTimeInterval BOOLoadMoreControllerFastAnimatedDuration = 0.25;
const NSTimeInterval BOOLoadMoreControllerSlowAnimatedDuration = 0.4;

@interface BOOLoadMoreController ()

@property (nonatomic) BOOLoadMoreControlState state;

@property (nonatomic) CGFloat pullingPercent;

@property (nonatomic, weak) UIScrollView *observable;

@property (nonatomic) CGFloat scrollContentInsetBottomBeforeLoad;

@end

@implementation BOOLoadMoreController

- (instancetype)initWithObservable:(UIScrollView *)observable {
    if (self = [super init]) {
        [self setLoadThreshold:0.f];
        self.extraBottomInsetWhenLoading = 0;
        self.placeAtBottomWhenLoading = YES;
        self.observable = observable;
        [self addScrollContenSizeObserver];
        [self addScrollContenOffsetObserver];
    }
    return self;
}

- (void)dealloc {
    [self removeScrollContenSizeObserver];
    [self removeScrollContenOffsetObserver];
}

- (UIEdgeInsets)scrollContentInset {
    return self.observable.contentInset;
}

- (CGPoint)scrollContentOffset {
    return self.observable.contentOffset;
}

- (CGSize)scrollContentSize {
    return self.observable.contentSize;
}

- (CGSize)scrollViewSize {
    return self.observable.frame.size;
}

- (CGFloat)scrollViewVisiableAreaMaxY {
    UIEdgeInsets inset = [self scrollContentInset];
    CGFloat scrollHeight = [self scrollViewSize].height;
    CGFloat contentHeight = [self scrollContentSize].height;
    return MAX(contentHeight + inset.bottom, scrollHeight - inset.top);
}

- (void)finishLoadingWithDelay:(NSTimeInterval)delay {
    if (self.state != BOOLoadMoreControlLoading) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(finishLoading)
                                               object:nil];
    [self performSelector:@selector(finishLoading)
               withObject:nil
               afterDelay:delay>0?delay:0];
}

- (void)finishLoading {
    
    if (self.state != BOOLoadMoreControlLoading) {
        return;
    }
    
    // remove observer to prevent interference
    [self removeScrollContenOffsetObserver];
    
    if (self.stateWillChangeBlock) {
        self.stateWillChangeBlock(self, self.state, BOOLoadMoreControlStateIdle);
    }
    
    // recovery inset
    UIEdgeInsets inset = [self scrollContentInset];
    [UIView animateWithDuration:BOOLoadMoreControllerSlowAnimatedDuration animations:^{
        UIEdgeInsets newInset = inset;
        newInset.bottom = self.scrollContentInsetBottomBeforeLoad;
        self.observable.contentInset = newInset;
        
        if (self.finishLoadAnimationBlock) {
            self.finishLoadAnimationBlock(self);
        }
        
    } completion:^(BOOL finished) {
        
        if (self.state != BOOLoadMoreControlStateIdle) {
            self.state = BOOLoadMoreControlStateIdle;
        }
        
        self.pullingPercent = 0.0;
        
        // add observer again
        [self addScrollContenOffsetObserver];
    }];
    
}

- (void)setState:(BOOLoadMoreControlState)state {
    BOOLoadMoreControlState old = self.state;
    
    _state = state;
    
    if (self.stateDidChangedBlock) {
        self.stateDidChangedBlock(self, old, state);
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    
    CGFloat percent = pullingPercent;
    if (percent < 0)
        percent = 0;
    else if (percent > 1)
        percent = 1;
    
    _pullingPercent = percent;
    
    if (self.pullingPercentChangeBlock) {
        self.pullingPercentChangeBlock(self, percent);
    }
}

- (void)didObservedContentOffsetChanged {
    
    CGFloat offset_y = [self scrollContentOffset].y;
    UIEdgeInsets inset = [self scrollContentInset];
    CGFloat scrollHeight = [self scrollViewSize].height;
    
    if (self.state == BOOLoadMoreControlLoading
        && self.extraBottomInsetWhenLoading > 0) {
        CGFloat newInsetBottom = self.scrollContentInsetBottomBeforeLoad + self.extraBottomInsetWhenLoading;
        if (newInsetBottom != inset.bottom) {
            UIEdgeInsets newInset = inset;
            newInset.bottom = newInsetBottom;
            self.observable.contentInset = newInset;
        }
        return;
    }
    
    CGFloat visiableMaxY = [self scrollViewVisiableAreaMaxY];
    CGFloat pullUpDistance = (offset_y + scrollHeight) - visiableMaxY;
    BOOL canLoad = self.loadThreshold < pullUpDistance;
    BOOL isDragging = self.observable.isDragging;
    
    if (!isDragging && self.state == BOOLoadMoreControlPulling) {
        // remove observer to prevent interference
        [self removeScrollContenOffsetObserver];
        
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLoadMoreControlLoading);
        }
        self.state = BOOLoadMoreControlLoading;
        self.scrollContentInsetBottomBeforeLoad = inset.bottom;
        
        BOOL needAnimation = (self.extraBottomInsetWhenLoading > 0 || self.placeAtBottomWhenLoading);
        [UIView animateWithDuration:needAnimation?BOOLoadMoreControllerFastAnimatedDuration:0 animations:^{
            
            if (self.extraBottomInsetWhenLoading > 0) {
                CGFloat newInsetBottom = self.scrollContentInsetBottomBeforeLoad + self.extraBottomInsetWhenLoading;
                UIEdgeInsets newInset = inset;
                newInset.bottom = newInsetBottom;
                self.observable.contentInset = newInset;
            }
            
            if (self.placeAtBottomWhenLoading) {
                CGPoint newContentOffset = self.observable.contentOffset;
                newContentOffset.y = (visiableMaxY - scrollHeight) + (self.extraBottomInsetWhenLoading>0?self.extraBottomInsetWhenLoading:0);
                [self.observable setContentOffset:newContentOffset animated:NO];
            }
            
        } completion:^(BOOL finished) {
            if (self.loadMoreExecuteBlock) {
                self.loadMoreExecuteBlock(self);
            }
            
            // add observer again
            [self addScrollContenOffsetObserver];
        }];
        
    } else if (isDragging && canLoad) {
        
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLoadMoreControlPulling);
        }
        if (self.state != BOOLoadMoreControlPulling) {
            self.state = BOOLoadMoreControlPulling;
        }
        
    } else {
        
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLoadMoreControlStateIdle);
        }
        self.state = BOOLoadMoreControlStateIdle;
        
        CGFloat pullingPer = 0;
        if (self.loadThreshold <= 0) {
            pullingPer = 1;
        } else {
            pullingPer = pullUpDistance/self.loadThreshold;
        }
        self.pullingPercent = pullingPer;
    }
}

- (void)didObservedContentSizeChanged {
    if (self.scrollContentSizeChangedBlock) {
        self.scrollContentSizeChangedBlock(self);
    }
}

#pragma mark - KVO监听
- (void)addScrollContenOffsetObserver {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.observable addObserver:self forKeyPath:BOOLoadMoreControllerKeyPathContentOffset options:options context:nil];
}

- (void)removeScrollContenOffsetObserver {
    [self.observable removeObserver:self forKeyPath:BOOLoadMoreControllerKeyPathContentOffset];
}

- (void)addScrollContenSizeObserver {
    [self.observable addObserver:self forKeyPath:BOOLoadMoreControllerKeyPathContentSize options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeScrollContenSizeObserver {
    [self.observable removeObserver:self forKeyPath:BOOLoadMoreControllerKeyPathContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:BOOLoadMoreControllerKeyPathContentOffset]) {
        [self didObservedContentOffsetChanged];
    } else if ([keyPath isEqualToString:BOOLoadMoreControllerKeyPathContentSize]) {
        [self didObservedContentSizeChanged];
    }
}

@end
