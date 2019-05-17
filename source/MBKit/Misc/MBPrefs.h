//
//  MBPrefs.h
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBConstants.h"

// 保存各项设置值的 key
extern NSString *MBProgramLiveAutoRefreshIntervalStoreIdentifier;
extern NSString *MBProgramListOperateItemsPostionStoreIdentifier;
extern NSString *MBListDayDateSectionHeaderFixedStoreIdentifier;
extern NSString *MBProgramRemindTimeStoreIdentifier;
extern NSString *MBRememberLastOpenedListTypeStoreIdentifier;
extern NSString *MBListDisplayNumInExpandedWidgetStoreIdentifier;
extern NSString *MBUseTapticPeekStoreIdentifier;
extern NSString *MBClickWidgetProgramItemShowDetail;

@interface MBPrefs : NSObject

+ (instancetype)shared;


/**
 直播情况（比分）自动更新频率
 */
@property (nonatomic, assign) MBProgramLiveAutoRefreshInterval liveAutoRefreshInterval;


/**
 重置'直播情况（比分）自动更新频率'

 @return 重置后的值
 */
- (MBProgramLiveAutoRefreshInterval)resetLiveAutoRefreshInterval;


/**
 节目列表操作项(刷新、到直播按钮)位置
 */
@property (nonatomic, assign) MBProgramListOperateItemsPostion listOperateItemsPosition;

/**
 重置'节目列表操作项(刷新、到直播按钮)位置'
 
 @return 重置后的值
 */
- (MBProgramListOperateItemsPostion)resetListOperateItemsPosition;

/**
 是否固定节目列表的日期头
 */
@property (nonatomic, assign) BOOL listDayDateSectionHeaderFixed;

/**
 重置'是否固定节目列表的日期头'
 
 @return 重置后的值
 */
- (BOOL)resetListDayDateSectionHeaderFixed;

/**
 节目提醒时间
 */
@property (nonatomic, assign) MBProgramRemindTime programRemindTime;

/**
 重置'节目提醒时间'
 
 @return 重置后的值
 */
- (MBProgramRemindTime)resetProgramRemindTime;

/**
 记住上一次打开的节目列表类型
 */
@property (nonatomic, assign) BOOL rememberLastOpenedListType;

/**
 重置'记住上一次打开的节目列表类型'
 
 @return 重置后的值
 */
- (BOOL)resetRememberLastOpenedListType;

/**
 上一次打开的节目列表类型。 如果不存在，则返回 NSNotFound
 */
@property (nonatomic, assign) NSInteger lastOpenedListType;

/**
 Widget展开显示节目数量
 */
@property (nonatomic, assign) MBListDisplayNumInExpandedWidget listDisplayNumInExpandedWidget;

/**
 重置'Widget展开显示节目数量'
 
 @return 重置后的值
 */
- (MBListDisplayNumInExpandedWidget)resetListDisplayNumInExpandedWidget;

/**
 是否启用触感反馈
 */
@property (nonatomic, assign) BOOL useTapticPeek;

/**
 重置'是否启用触感反馈'
 
 @return 重置后的值
 */
- (BOOL)resetUseTapticPeek;


/**
 Widget的节目点击后是否详情
 */
@property (nonatomic, assign) BOOL clickWidgetProgramItemShowDetail;

/**
 重置'Widget的节目点击后是否详情'
 
 @return 重置后的值
 */
- (BOOL)resetClickWidgetProgramItemShowDetail;

@end


@interface UITraitCollection (MBPrefs)

- (BOOL)tapticPeekIfPossible;

@end
