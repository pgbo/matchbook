//
//  MBConstants.h
//  matchbook
//
//  Created by guangbool on 2017/6/20.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>

// 应用分组名称
extern NSString *const MBAppGroupName;

// 节目数据存放目录名
extern NSString *const MBProgramDirectoryName;

// 偏好设置数据存放目录名
extern NSString *const MBPrefsDirectoryName;

// 存放「全部节目」的有序字典的 key，该字典的 key-value 形式为 <program_id(string 类型), program_content(MBMatchProgram 类型)>
extern NSString *const MBAllProgramsOrderedDictionaryStoreKey;

// 存放「关注节目」的 id 列表的 key
extern NSString *const MBFocusedProgramIdsStoreKey;

// 存放「关注节目id和提醒id」的字典的 key。该字典以 program id 为 key，以 EKEvent identifier 为 value
extern NSString *const MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey;


// 存放「查询策略配置信息」的 key
extern NSString *const MBQueryStrategyConfigStoreKey;

// 存放「节目数据的保存时间」的 key
extern NSString *const MBProgramsSavedTimestampStoreKey;

// 存放「节目数据的提供者名称」的 key
extern NSString *const MBProgramDatasProviderStoreKey;


/**
 直播情况（比分）自动更新频率
 */
typedef NS_ENUM(NSInteger, MBProgramLiveAutoRefreshInterval) {
    // 不自动更新
    MBProgramLiveNotAutoRefresh = -1,
    // 10 s
    MBProgramLiveAutoRefreshInterval_10s = 10,
    // 20 s
    MBProgramLiveAutoRefreshInterval_20s = 20,
    // 30 s
    MBProgramLiveAutoRefreshInterval_30s = 30,
    // 60s
    MBProgramLiveAutoRefreshInterval_60s = 60,
};

// 直播情况（比分）自动更新频率的全部枚举值集合
extern NSArray<NSNumber*>* MBProgramLiveAutoRefreshInterval_allValues();

/**
 节目列表操作项(刷新、到直播按钮)位置
 */
typedef NS_ENUM(NSInteger, MBProgramListOperateItemsPostion) {
    MBProgramListOperateItemsPostionRight = 0,
    MBProgramListOperateItemsPostionLeft,
};

// 节目列表操作项(刷新、到直播按钮)位置的全部枚举值集合
extern NSArray<NSNumber*>* MBProgramListOperateItemsPostion_allValues();

/**
 节目提醒时间
 */
typedef NS_ENUM(NSInteger, MBProgramRemindTime) {
    // 节目开始时
    MBProgramRemindWhenBegin = 0,
    // 1 分钟前
    MBProgramRemindBefore1Min = 1,
    // 5 分钟前
    MBProgramRemindBefore5Min = 5,
    // 10 分钟前
    MBProgramRemindBefore10Min = 10,
    // 30 分钟前
    MBProgramRemindBefore30Min = 30,
};

// 节目提醒时间的全部枚举值集合
extern NSArray<NSNumber*>* MBProgramRemindTime_allValues();



/**
 Widget展开显示节目数量
 */
typedef NS_ENUM(NSInteger, MBListDisplayNumInExpandedWidget) {
    // 2条
    MBListInExpandedWidgetDisplay2Item = 2,
    // 3条
    MBListInExpandedWidgetDisplay3Item = 3,
    // 4条
    MBListInExpandedWidgetDisplay4Item = 4,
    // 5条
    MBListInExpandedWidgetDisplay5Item = 5,
};

// Widget展开显示节目数量全部枚举值集合
extern NSArray<NSNumber*>* MBListDisplayNumInExpandedWidget_allValues();
