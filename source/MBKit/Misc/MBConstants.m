//
//  MBConstants.m
//  matchbook
//
//  Created by guangbool on 2017/6/20.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBConstants.h"

// 应用分组名称
NSString *const MBAppGroupName = @"group.com.devbool.mb";

// 节目数据存放目录名
NSString *const MBProgramDirectoryName = @"ProgramData";

// 偏好设置数据存放目录名
NSString *const MBPrefsDirectoryName = @"PrefsData";

// 存放「全部节目」的有序字典的 key。该字典的 key-value 形式为 <program_id(string 类型), program_content(MBMatchProgram 类型)>
NSString *const MBAllProgramsOrderedDictionaryStoreKey = @"AllProgramsOrderedDictionary";

// 存放「关注节目」的 id 列表的 key
NSString *const MBFocusedProgramIdsStoreKey = @"kFocusedProgramIds";

// 存放「关注节目id和提醒id」的字典的 key。该字典以 program id 为 key，以 EKEvent identifier 为 value
NSString *const MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey = @"kFocusedProgramIdAndRemindEventIdDictionary";


// 存放「查询策略配置信息」的 key
NSString *const MBQueryStrategyConfigStoreKey = @"kQueryStrategyConfig";

// 存放「节目数据的保存时间」的 key
NSString *const MBProgramsSavedTimestampStoreKey = @"kProgramsSavedTimestamp";

// 存放「节目数据的提供者名称」的 key
NSString *const MBProgramDatasProviderStoreKey = @"kProgramDatasProvider";


// 直播情况（比分）自动更新频率的全部枚举值集合
NSArray<NSNumber*>* MBProgramLiveAutoRefreshInterval_allValues() {
    static NSArray<NSNumber*> *RefreshInterval_allValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RefreshInterval_allValues = @[@(MBProgramLiveNotAutoRefresh),
                                      @(MBProgramLiveAutoRefreshInterval_10s),
                                      @(MBProgramLiveAutoRefreshInterval_20s),
                                      @(MBProgramLiveAutoRefreshInterval_30s),
                                      @(MBProgramLiveAutoRefreshInterval_60s)];
    });
    return RefreshInterval_allValues;
}


// 节目列表操作项(刷新、到直播按钮)位置的全部枚举值集合
NSArray<NSNumber*>* MBProgramListOperateItemsPostion_allValues() {
    static NSArray<NSNumber*> *OperateItemsPostion_allValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OperateItemsPostion_allValues = @[@(MBProgramListOperateItemsPostionRight),
                                          @(MBProgramListOperateItemsPostionLeft)];
    });
    return OperateItemsPostion_allValues;
}


// 节目提醒时间的全部枚举值集合
NSArray<NSNumber*>* MBProgramRemindTime_allValues() {
    static NSArray<NSNumber*> *RemindTime_allValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RemindTime_allValues = @[@(MBProgramRemindWhenBegin),
                                 @(MBProgramRemindBefore1Min),
                                 @(MBProgramRemindBefore5Min),
                                 @(MBProgramRemindBefore10Min),
                                 @(MBProgramRemindBefore30Min)];
    });
    return RemindTime_allValues;
}

// Widget展开显示节目数量全部枚举值集合
NSArray<NSNumber*>* MBListDisplayNumInExpandedWidget_allValues() {
    static NSArray<NSNumber*> *DisplayNumInExpandedWidget_allValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DisplayNumInExpandedWidget_allValues = @[@(MBListInExpandedWidgetDisplay2Item),
                                 @(MBListInExpandedWidgetDisplay3Item),
                                 @(MBListInExpandedWidgetDisplay4Item),
                                 @(MBListInExpandedWidgetDisplay5Item)];
    });
    return DisplayNumInExpandedWidget_allValues;
}
