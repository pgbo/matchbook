//
//  NSString+MBApp.h
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBConstants.h"

@interface NSString (MBApp)


/**
 直播情况（比分）自动更新频率的描述

 @param refreshInterval 更新频率类型
 @return 描述
 */
+ (NSString *)descriptionOfLiveAutoRefreshInterval:(MBProgramLiveAutoRefreshInterval)refreshInterval;


/**
 节目列表操作项(刷新、到直播按钮)位置的描述
 
 @param postion 位置类型
 @return 描述
 */
+ (NSString *)descriptionOfListOperateItemsPostion:(MBProgramListOperateItemsPostion)postion;


/**
 节目提醒时间的描述
 
 @param remindTime 提醒时间类型
 @return 描述
 */
+ (NSString *)descriptionOfProgramRemindTime:(MBProgramRemindTime)remindTime;


/**
 布尔设置项的值描述

 @param boolValue 布尔值
 @return 描述
 */
+ (NSString *)descriptionOfPreferenceBoolValue:(BOOL)boolValue;


/**
 Widget展开显示节目数量的描述
 
 @param displayNum 显示数量
 @return 描述
 */
+ (NSString *)descriptionOfListDisplayNumInExpandedWidget:(MBListDisplayNumInExpandedWidget)displayNum;

@end
