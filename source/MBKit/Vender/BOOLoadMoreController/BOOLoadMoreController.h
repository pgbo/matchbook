//
//  BOOLoadMoreController.h
//  Sample
//
//  Created by guangbool on 2017/4/24.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 刷新控件的状态
 */
typedef NS_ENUM(NSUInteger, BOOLoadMoreControlState) {
    /** 普通闲置状态 */
    BOOLoadMoreControlStateIdle = 1,
    /** 松开就可以进行加载的状态 */
    BOOLoadMoreControlPulling,
    /** 正在加载中的状态 */
    BOOLoadMoreControlLoading
};

@interface BOOLoadMoreController : NSObject

// 滚动视图的 contentInset
@property (nonatomic, readonly) UIEdgeInsets scrollContentInset;

// 滚动视图的 contentOffset
@property (nonatomic, readonly) CGPoint scrollContentOffset;

// 滚动视图的 contentSize
@property (nonatomic, readonly) CGSize scrollContentSize;

// 滚动视图的 size
@property (nonatomic, readonly) CGSize scrollViewSize;

// 滚动视图可视区域的最大 Y 值
@property (nonatomic, readonly) CGFloat scrollViewVisiableAreaMaxY;

// 刷新状态
@property (nonatomic, readonly) BOOLoadMoreControlState state;

/**
 拉拽程度. 值在 0、1之间。当 loadThreshold <=0 时，pullingPercent 一直等于 1
 。
 */
@property (nonatomic, readonly) CGFloat pullingPercent;

/**
 触发加载的阀值，默认为 0
 */
@property (nonatomic, assign) CGFloat loadThreshold;

/**
 在加载时额外的 bottom inset，默认为 0
 */
@property (nonatomic, assign) CGFloat extraBottomInsetWhenLoading;

/**
 在加载时是否停留在底部，默认为 YES
 */
@property (nonatomic, assign) CGFloat placeAtBottomWhenLoading;

/**
 状态将要改变的 block
 */
@property (nonatomic, copy) void(^stateWillChangeBlock)(BOOLoadMoreController *controller, BOOLoadMoreControlState current, BOOLoadMoreControlState willState);

/**
 结束加载动画的 block，自定义的一些动画可以在这执行
 */
@property (nonatomic, copy) void(^finishLoadAnimationBlock)(BOOLoadMoreController *controller);

/**
 状态改变的 block
 */
@property (nonatomic, copy) void(^stateDidChangedBlock)(BOOLoadMoreController *controller, BOOLoadMoreControlState old, BOOLoadMoreControlState currentState);


/**
 下拉程度变化 block. pullingPercent 的值在 0、1之间
 */
@property (nonatomic, copy) void(^pullingPercentChangeBlock)(BOOLoadMoreController *controller, CGFloat pullingPercent);


/**
 加载 block
 */
@property (nonatomic, copy) void(^loadMoreExecuteBlock)(BOOLoadMoreController *controller);


/**
 scrollView 的 contenSize 改变的 block
 */
@property (nonatomic, copy) void(^scrollContentSizeChangedBlock)(BOOLoadMoreController *controller);

// 被观察者
@property (nonatomic, weak, readonly) UIScrollView *observable;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObservable:(UIScrollView *)observable;

/**
 主动结束加载

 @param delay 恢复为 idle 状态的延时时间
 */
- (void)finishLoadingWithDelay:(NSTimeInterval)delay;

@end


@protocol BOOLoadMoreControlProtocol <NSObject>

@optional

- (void)stateWillChangeFromCurrent:(BOOLoadMoreControlState)fromCurrentState toState:(BOOLoadMoreControlState)toState;
- (void)stateDidChangedFromOld:(BOOLoadMoreControlState)fromOldState toCurrentState:(BOOLoadMoreControlState)toCurrentState;
- (void)animateWhenFinishRefresh;
- (void)pullingPercentChangeTo:(CGFloat)pullingPercent;

@end
