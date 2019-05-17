//
//  LFPageInformationDisplayItem.h
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LFPageInformationAnimating.h"

@protocol LFPageInformationDisplayView <NSObject>

/**
 *  在添加到容器视图时是否隐藏
 */
- (BOOL)lfpi_hideBeforeAddIntoContainerView;

/**
 *  是否居中显示
 */
- (BOOL)lfpi_aliginCenter;

/**
 *  hide 后是否从父视图上删除
 */
- (BOOL)lfpi_removeFromSuperViewWhenHide;

/**
 *  视图内容尺寸
 */
- (CGSize)lfpi_intrinsicContentSize;

@end

@class LFPageInformationDisplayItem;
@protocol LFPageInformationDisplayItemDelegate <NSObject>

@optional
- (void)lfpi_informationViewDidDisplay:(LFPageInformationDisplayItem *)displayItem;

- (void)lfpi_informationViewDidHide:(LFPageInformationDisplayItem *)displayItem;

@end


@interface LFPageInformationDisplayItem : NSObject

/**
 *  展示信息的视图
 */
@property (nonatomic, strong, readonly) UIView<LFPageInformationDisplayView> *pageInformationDisplayView;

/**
 *  informationView 的容器视图
 */
@property (nonatomic, strong, readonly) UIView *pageInformationContainerView;

/**
 *  代理
 */
@property (nonatomic, weak) id<LFPageInformationDisplayItemDelegate> pageInformationDisplayDelegate;

/**
 *  指定动画
 */
@property (nonatomic, strong) id<LFPageInformationAnimating> pageInformationAnimation;

- (instancetype)initWithPageInformationDisplayView:(UIView<LFPageInformationDisplayView> *)pageInformationDisplayView
                      pageInformationContainerView:(UIView *)pageInformationContainerView;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  显示
 *  @param animated 是否动画，如果`animated`为`YES`, 且存在`pageInformationAnimation`，那么会使用动画
 */
- (void)displayWithAnimated:(BOOL)animated;

/**
 *  消失
 *  @param animated 是否动画，如果`animated`为`YES`, 且存在`pageInformationAnimation`，那么会使用动画
 */
- (void)hideWithAnimated:(BOOL)animated;

@end
