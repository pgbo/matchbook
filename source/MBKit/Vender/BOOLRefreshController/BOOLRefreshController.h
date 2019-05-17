//
//  BOOLRefreshController.h
//
//  Created by guangbool on 2017/2/9.
//  Copyright © 2017年 guangbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 刷新控件的状态
 */
typedef NS_ENUM(NSUInteger, BOOLRefreshControlState) {
    /** 普通闲置状态 */
    BOOLRefreshControlStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    BOOLRefreshControlPulling,
    /** 正在刷新中的状态 */
    BOOLRefreshControlRefreshing
};


/**
 刷新控件控制器，抽离出刷新控件的算法。UI 变来变去，但算法是不变的
 */
@interface BOOLRefreshController : NSObject

// 刷新状态
@property (nonatomic, readonly) BOOLRefreshControlState state;

// 下拉程度. 值在 0、1之间
@property (nonatomic, readonly) CGFloat pullingPercent;

// 刷新阀值. 大于 0，默认 45
@property (nonatomic) CGFloat refreshThreshold;

/**
状态将要改变的 block
*/
@property (nonatomic, copy) void(^stateWillChangeBlock)(BOOLRefreshController *controller, BOOLRefreshControlState current, BOOLRefreshControlState willState);

/**
 结束刷新动画的 block，自定义的一些动画可以在这执行
 */
@property (nonatomic, copy) void(^finishRefreshAnimationBlock)(BOOLRefreshController *controller);

/**
 状态改变的 block
 */
@property (nonatomic, copy) void(^stateDidChangedBlock)(BOOLRefreshController *controller, BOOLRefreshControlState old, BOOLRefreshControlState currentState);


/**
 下拉程度变化 block. pullingPercent 的值在 0、1之间
 */
@property (nonatomic, copy) void(^pullingPercentChangeBlock)(BOOLRefreshController *refreshController, CGFloat pullingPercent);


/**
 刷新 block
 */
@property (nonatomic, copy) void(^refreshExecuteBlock)(BOOLRefreshController *refreshController);

// 被观察者
@property (nonatomic, weak, readonly) UIScrollView *observable;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObservable:(UIScrollView *)observable;


/**
 主动结束刷新
 */
- (void)finishRefreshing;

@end


@protocol BOOLRefreshControlProtocol <NSObject>

@optional

- (void)stateWillChangeFromCurrent:(BOOLRefreshControlState)fromCurrentState toState:(BOOLRefreshControlState)toState;
- (void)stateDidChangedFromOld:(BOOLRefreshControlState)fromOldState toCurrentState:(BOOLRefreshControlState)toCurrentState;
- (void)animateWhenFinishRefresh;
- (void)pullingPercentChangeTo:(CGFloat)pullingPercent;

@end
