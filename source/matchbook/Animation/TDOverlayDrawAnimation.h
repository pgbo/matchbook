//
//  TDOverlayDrawAnimation.h
//  tinyDict
//
//  Created by guangbool on 2017/5/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  抽出方式
 */
typedef NS_ENUM(NSUInteger, TDOverlayDrawAnimationStyle) {
    TDOverlayDrawAnimationDrawFromRight = 0,     // 从右边抽出
    TDOverlayDrawAnimationDrawFromLeft,          // 从左边抽出
    TDOverlayDrawAnimationDrawFromTop,           // 从顶部抽出
    TDOverlayDrawAnimationDrawFromBottom,       // 从底部抽出
};

@class TDOverlayDrawAnimationContext;


/**
 抽屉动画
 */
@interface TDOverlayDrawAnimation : NSObject

/**
 *  抽出方式，默认 `TDOverlayDrawAnimationDrawFromRight`
 */
@property (nonatomic) TDOverlayDrawAnimationStyle drawStyle;

/**
 *  是否抽到容器视图的居中位置，默认为 `NO`，为`NO`时根据 `drawStyle` 抽到距离最近的边停止
 */
@property (nonatomic) BOOL drawToAlignCenter;

/**
 *  在显示抽屉时覆盖背景的透明度, 默认为 1
 */
@property (nonatomic) CGFloat overlayAlphaWhenDrawOut;

/**
 *  在隐藏抽屉时覆盖背景的透明度, 默认为 0
 */
@property (nonatomic) CGFloat overlayAlphaWhenDrawAway;

/**
 *  覆盖视图（带有透明度的覆盖层）
 */
@property (nonatomic) UIView *overlayBackgroudView;

/**
 *  抽屉视图
 */
@property (nonatomic) UIView *drawView;

/**
 *  进行动画的容器视图的大小
 */
@property (nonatomic) CGSize animationContainerSize;

- (void)animate:(TDOverlayDrawAnimationContext *)context;

@end


/**
 抽屉动画 context
 */
@interface TDOverlayDrawAnimationContext : NSObject

@property (nonatomic) BOOL fromVisible;
@property (nonatomic) BOOL toVisible;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) void(^animationFinishedHandler)(BOOL finished, BOOL fromVisible, BOOL toVisible);

@end
