//
//  NSDate+TDKit.m
//  matchbook
//
//  Created by 彭光波 on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "NSDate+TDKit.h"

@implementation NSDate (TDKit)

+ (NSCalendar *)GregorianCalendar {
    static NSCalendar *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return instance;
}

- (void)getYear:(NSInteger *)year
          month:(NSInteger *)month
            day:(NSInteger *)day
        weekday:(NSInteger *)weekday {
    
    NSDateComponents *comps = [[self.class GregorianCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:self];
    
    if (year != NULL) {
        *year = [comps year];
    }
    
    if (month != NULL) {
        *month = [comps month];
    }
    
    if (day != NULL) {
        *day = [comps day];
    }
    
    if (weekday != NULL) {
        *weekday = [comps weekday];
    }
}

- (NSInteger)year {
    NSInteger year;
    [self getYear:&year month:NULL day:NULL weekday:NULL];
    return year;
}

- (NSInteger)month {
    NSInteger month;
    [self getYear:NULL month:&month day:NULL weekday:NULL];
    return month;
}

- (NSInteger)day {
    NSInteger day;
    [self getYear:NULL month:NULL day:&day weekday:NULL];
    return day;
}

- (BOOL)sameDayTo:(NSDate *)another {
    if (!another) return NO;
    
    NSInteger thisYear, thisMonth, thisDay;
    [self getYear:&thisYear month:&thisMonth day:&thisDay weekday:NULL];
    
    NSInteger anotherYear, anotherMonth, anotherDay;
    [another getYear:&anotherYear month:&anotherMonth day:&anotherDay weekday:NULL];
    
    return (thisYear == anotherYear && thisMonth == anotherMonth && thisDay == anotherDay);
}

- (NSDate *)sameDayWithHour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second {
    NSInteger thisYear, thisMonth, thisDay;
    [self getYear:&thisYear month:&thisMonth day:&thisDay weekday:NULL];
    return [self.class dateWithYear:thisYear month:thisMonth day:thisDay hour:hour minute:minute second:second];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSInteger)daysNumSinceAnotherDay:(NSDate *)anotherDay {
    NSAssert(anotherDay != nil, @"anotherDay can't be nil");
    NSDate *theDay = [self sameDayWithHour:0 minute:0 second:0];
    NSTimeInterval theDayTime = [theDay timeIntervalSinceReferenceDate];
    
    NSDate *theOherDay = [anotherDay sameDayWithHour:0 minute:0 second:0];
    NSTimeInterval theOtherDayTime = [theOherDay timeIntervalSinceReferenceDate];
    
    NSInteger daysNum = (theDayTime - theOtherDayTime)/86400;
    
    return daysNum;
}

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    [comps setHour:hour];
    [comps setMinute:minute];
    [comps setSecond:second];
    NSDate *date = [self.GregorianCalendar dateFromComponents:comps];
    return date;
}

+ (NSString *)localWeekday:(NSUInteger)weekday {
    if (weekday == 1) return @"周日";
    if (weekday == 2) return @"周一";
    if (weekday == 3) return @"周二";
    if (weekday == 4) return @"周三";
    if (weekday == 5) return @"周四";
    if (weekday == 6) return @"周五";
    if (weekday == 7) return @"周六";
    return nil;
}

- (NSString *)dayOfMonthFormattedResult {
    NSInteger month, day;
    [self getYear:NULL month:&month day:&day weekday:NULL];
    return [NSString stringWithFormat:@"%@月%@日", @(month), @(day)];
}

- (NSString *)dayOfMonthAndDayOfWeekFormattedResult {
    NSInteger month, day, weekday;
    [self getYear:NULL month:&month day:&day weekday:&weekday];
    return [NSString stringWithFormat:@"%@月%@日 %@", @(month), @(day), [NSDate localWeekday:weekday]];
}

- (NSString *)dayOfYeardayAndDayOfWeekFormattedResult {
    NSInteger year, month, day, weekday;
    [self getYear:&year month:&month day:&day weekday:&weekday];
    return [NSString stringWithFormat:@"%@年%@月%@日 %@", @(year), @(month), @(day), [NSDate localWeekday:weekday]];
}

@end
