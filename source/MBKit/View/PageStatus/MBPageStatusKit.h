//
//  MBPageStatusKit.h
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBDataRequestStatusView.h"
#import "LFPageInformationDisplay.h"

@interface MBPageStatusKit : NSObject

// 容器视图
@property (nonatomic, weak, readonly) UIView *containerView;

/**
 * `containerView`的 size。
 * 默认为 `containerView` 的 `bounds.size`
 */
@property (nonatomic, assign) CGSize containerSize;

/**
 * 正在加载状态文字。
 * 默认为`加载中...`
 */
@property (nonatomic, copy) NSAttributedString *loadingText;

/**
 加载的动画图片集合
 */
@property (nonatomic, copy) NSArray<UIImage *> *loadingImages;


/**
 * 「无数据」状态文字。
 * viewTouchable 为 YES 时默认为｀暂无数据\n点击屏幕重试｀，为 NO 时默认为｀暂无数据｀
 */
@property (nonatomic, copy) NSAttributedString*(^noDataTextGetter)(MBPageStatusKit *kit, BOOL viewTouchable);

/**
 「无数据」状态视图是否可点击。
 默认为 YES
 */
@property (nonatomic, assign) BOOL noDataViewTouchable;

/**
 「无数据」状态的图片
 */
@property (nonatomic) UIImage *noDataImage;

/**
 「无数据」状态操作视图点击操作
 */
@property (nonatomic, copy) void(^noDataViewTouchBlock)(MBPageStatusKit *kit);


/**
 * 「无网络连接」状态文字。
 * viewTouchable 为 YES 时默认为｀网络状态待提升\n点击屏幕重试｀，为 NO 时默认为｀网络状态待提升｀
 */
@property (nonatomic, copy) NSAttributedString*(^noNetworkTextGetter)(MBPageStatusKit *kit, BOOL viewTouchable);

/**
 「无网络连接」状态视图是否可点击。
 默认为 YES
 */
@property (nonatomic, assign) BOOL noNetworkViewTouchable;

/**
 「无网络连接」状态的图片
 */
@property (nonatomic) UIImage *noNetworkImage;

/**
 「无网络连接」状态操作视图点击操作
 */
@property (nonatomic, copy) void(^noNetworkViewTouchBlock)(MBPageStatusKit *kit);


/**
 * 「一般出错」状态文字。
 * viewTouchable 为 YES 时默认为｀Sorry, 貌似出错了\n点击屏幕重试｀，为 NO 时默认为｀Sorry, 貌似出错了｀
 */
@property (nonatomic, copy) NSAttributedString*(^normalErrorTextGetter)(MBPageStatusKit *kit, BOOL viewTouchable);

/**
 「一般出错」状态视图是否可点击。
 默认为 YES
 */
@property (nonatomic, assign) BOOL normalErrorViewTouchable;

/**
 「一般出错」状态的图片
 */
@property (nonatomic) UIImage *normalErrorImage;

/**
 「一般出错」状态操作视图点击操作
 */
@property (nonatomic, copy) void(^normalErrorViewTouchBlock)(MBPageStatusKit *kit);

- (instancetype)initWithContainerView:(UIView *)containerView;
- (instancetype)init NS_UNAVAILABLE;

- (void)showLoading;
- (void)showNoData;
- (void)showNoNetwork;
- (void)showNormalError;
- (void)hide;

+ (NSAttributedString *)createAttributedTextWithText:(NSString *)text
                                                font:(UIFont *)font
                                           textColor:(UIColor *)textColor;

@end

