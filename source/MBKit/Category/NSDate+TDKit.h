//
//  NSDate+TDKit.h
//  matchbook
//
//  Created by 彭光波 on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TDKit)

@property (nonatomic, readonly) NSInteger year; ///< Year component
@property (nonatomic, readonly) NSInteger month; ///< Month component (1~12)
@property (nonatomic, readonly) NSInteger day; ///< Day component (1~31)

- (BOOL)sameDayTo:(NSDate *)another;

- (NSDate *)sameDayWithHour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second;

- (NSDate *)dateByAddingDays:(NSInteger)days;


/**
 当前日期距离另一个日期的天数。
 如果当前日期小于另一个日期，那么结果可能为负数。

 @param anotherDay 另一个日期
 @return 两个日期间的天数
 */
- (NSInteger)daysNumSinceAnotherDay:(NSDate *)anotherDay;

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second;


/**
 返回'5月12日'形式的格式化结果
 
 @return 格式化结果
 */
- (NSString *)dayOfMonthFormattedResult;

/**
 返回'5月12日 周二'形式的格式化结果

 @return 格式化结果
 */
- (NSString *)dayOfMonthAndDayOfWeekFormattedResult;

/**
 返回'2017年5月12日 周二'形式的格式化结果
 
 @return 格式化结果
 */
- (NSString *)dayOfYeardayAndDayOfWeekFormattedResult;

@end
