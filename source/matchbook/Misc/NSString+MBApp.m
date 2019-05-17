//
//  NSString+MBApp.m
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "NSString+MBApp.h"

@implementation NSString (MBApp)

/**
 直播情况（比分）自动更新频率的描述
 
 @param refreshInterval 更新频率类型
 @return 描述
 */
+ (NSString *)descriptionOfLiveAutoRefreshInterval:(MBProgramLiveAutoRefreshInterval)refreshInterval {
    NSString *desc = nil;
    switch (refreshInterval) {
        case MBProgramLiveNotAutoRefresh:
            desc = @"不自动更新";
            break;
        case MBProgramLiveAutoRefreshInterval_10s:
            desc = @"10秒";
            break;
        case MBProgramLiveAutoRefreshInterval_20s:
            desc = @"20秒";
            break;
        case MBProgramLiveAutoRefreshInterval_30s:
            desc = @"30秒";
            break;
        case MBProgramLiveAutoRefreshInterval_60s:
            desc = @"60秒";
            break;
    }
    return desc;
}


/**
 节目列表操作项(刷新、到直播按钮)位置的描述
 
 @param postion 位置类型
 @return 描述
 */
+ (NSString *)descriptionOfListOperateItemsPostion:(MBProgramListOperateItemsPostion)postion {
    NSString *desc = nil;
    switch (postion) {
        case MBProgramListOperateItemsPostionRight:
            desc = @"右边";
            break;
        case MBProgramListOperateItemsPostionLeft:
            desc = @"左边";
            break;
    }
    return desc;
}


/**
 节目提醒时间的描述
 
 @param remindTime 提醒时间类型
 @return 描述
 */
+ (NSString *)descriptionOfProgramRemindTime:(MBProgramRemindTime)remindTime {
    NSString *desc = nil;
    switch (remindTime) {
        case MBProgramRemindWhenBegin:
            desc = @"节目开始时";
            break;
        case MBProgramRemindBefore1Min:
            desc = @"1分钟前";
            break;
        case MBProgramRemindBefore5Min:
            desc = @"5分钟前";
            break;
        case MBProgramRemindBefore10Min:
            desc = @"10分钟前";
            break;
        case MBProgramRemindBefore30Min:
            desc = @"30分钟前";
            break;
    }
    return desc;
}

/**
 布尔设置项的值描述
 
 @param boolValue 布尔值
 @return 描述
 */
+ (NSString *)descriptionOfPreferenceBoolValue:(BOOL)boolValue {
    return boolValue?@"是":@"否";
}


/**
 Widget展开显示节目数量的描述
 
 @param displayNum 显示数量
 @return 描述
 */
+ (NSString *)descriptionOfListDisplayNumInExpandedWidget:(MBListDisplayNumInExpandedWidget)displayNum {
    return [NSString stringWithFormat:@"%@条", @(displayNum)];
}

@end
