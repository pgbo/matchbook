//
//  BOOLRefreshController.m
//
//  Created by guangbool on 2017/2/9.
//  Copyright © 2017年 guangbool. All rights reserved.
//

#import "BOOLRefreshController.h"

NSString *const BOOLRefreshControllerKeyPathContentOffset = @"contentOffset";
const NSTimeInterval BOOLRefreshControllerFastAnimatedDuration = 0.25;
const NSTimeInterval BOOLRefreshControllerSlowAnimatedDuration = 0.4;

@interface BOOLRefreshController ()

@property (nonatomic) BOOLRefreshControlState state;

@property (nonatomic) CGFloat pullingPercent;

@property (nonatomic, weak) UIScrollView *observable;

@property (nonatomic) CGFloat observableContentInsetTopBeforeRefresh;

@end

@implementation BOOLRefreshController

- (instancetype)initWithObservable:(UIScrollView *)observable {
    if (self = [super init]) {
        [self setRefreshThreshold:45.f];
        self.observable = observable;
        [self addObservers];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)finishRefreshing {
    
    // 移除监听，防止干扰
    [self removeObservers];
    
    if (self.stateWillChangeBlock) {
        self.stateWillChangeBlock(self, self.state, BOOLRefreshControlStateIdle);
    }
    
    // 恢复inset和offset
    UIEdgeInsets c_inset = self.observable.contentInset;
    [UIView animateWithDuration:BOOLRefreshControllerSlowAnimatedDuration animations:^{
        
        self.observable.contentInset = UIEdgeInsetsMake(self.observableContentInsetTopBeforeRefresh, c_inset.left, c_inset.bottom, c_inset.right);
        
        if (self.finishRefreshAnimationBlock) {
            self.finishRefreshAnimationBlock(self);
        }
        
    } completion:^(BOOL finished) {
        
        self.pullingPercent = 0.0;
        
        if (self.state != BOOLRefreshControlStateIdle) {
            self.state = BOOLRefreshControlStateIdle;
        }
        // 重新添加监听
        [self addObservers];
    }];
}

- (void)didObservedContentOffsetChanged {
    CGFloat c_offset_y = self.observable.contentOffset.y;
    UIEdgeInsets c_inset = self.observable.contentInset;
    CGFloat c_inset_top = c_inset.top;
    
    // 在刷新的refreshing状态
    if (self.state == BOOLRefreshControlRefreshing) {
        
        // 停留解决
        CGFloat newTop = self.observableContentInsetTopBeforeRefresh + self.refreshThreshold;
        if (c_inset_top != newTop) {
            // 增加滚动区域top
            self.observable.contentInset = UIEdgeInsetsMake(newTop, c_inset.left, c_inset.bottom, c_inset.right);
        }
        return;
    }
    
    BOOL canRefreshPosition = (-c_offset_y) > (c_inset_top + self.refreshThreshold);
    BOOL isDragging = self.observable.isDragging;
    
    if (!isDragging && self.state == BOOLRefreshControlPulling) {
        // 移除监听，防止干扰
        [self removeObservers];
        
        // 进行刷新
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLRefreshControlRefreshing);
        }
        self.state = BOOLRefreshControlRefreshing;
        self.observableContentInsetTopBeforeRefresh = c_inset_top;
        
        [UIView animateWithDuration:BOOLRefreshControllerFastAnimatedDuration animations:^{
            CGFloat newTop = self.observableContentInsetTopBeforeRefresh + self.refreshThreshold;
            // 增加滚动区域top
            self.observable.contentInset = UIEdgeInsetsMake(newTop, c_inset.left, c_inset.bottom, c_inset.right);
            // 设置滚动位置
            [self.observable setContentOffset:CGPointMake(self.observable.contentOffset.x, -newTop) animated:NO];
        } completion:^(BOOL finished) {
            if (self.refreshExecuteBlock) {
                self.refreshExecuteBlock(self);
            }
            
            // 重新添加监听
            [self addObservers];
        }];
    } else if (isDragging && canRefreshPosition) {
    
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLRefreshControlPulling);
        }
        if (self.state != BOOLRefreshControlPulling) {
            self.state = BOOLRefreshControlPulling;
        }
    } else {
        
        if (self.stateWillChangeBlock) {
            self.stateWillChangeBlock(self, self.state, BOOLRefreshControlStateIdle);
        }
        self.state = BOOLRefreshControlStateIdle;
        CGFloat pullingPer = (-c_offset_y - c_inset_top)/self.refreshThreshold;
        self.pullingPercent = pullingPer;
    }
}

- (void)setRefreshThreshold:(CGFloat)refreshThreshold {
    _refreshThreshold = refreshThreshold;
    if (refreshThreshold <= 0) {
        _refreshThreshold = 45.f;
    }
}

- (void)setState:(BOOLRefreshControlState)state {
    BOOLRefreshControlState old = self.state;
    
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

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.observable addObserver:self forKeyPath:BOOLRefreshControllerKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers {
    [self.observable removeObserver:self forKeyPath:BOOLRefreshControllerKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:BOOLRefreshControllerKeyPathContentOffset]) {
        [self didObservedContentOffsetChanged];
    }
}

@end
