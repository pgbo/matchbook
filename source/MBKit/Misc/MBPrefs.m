//
//  MBPrefs.m
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBPrefs.h"
#import "MMWormhole.h"
#import "UITraitCollection+TDKit.h"

// 保存各项设置值的 key
NSString *MBProgramLiveAutoRefreshIntervalStoreIdentifier = @"liveAutoRefreshInterval";
NSString *MBProgramListOperateItemsPostionStoreIdentifier = @"listOperateItemsPosition";
NSString *MBListDayDateSectionHeaderFixedStoreIdentifier = @"listDayDateSectionHeaderFixed";
NSString *MBProgramRemindTimeStoreIdentifier = @"programRemindTime";
NSString *MBRememberLastOpenedListTypeStoreIdentifier = @"rememberLastOpenedListType";
NSString *MBListDisplayNumInExpandedWidgetStoreIdentifier = @"listDisplayNumInExpandedWidget";
NSString *MBUseTapticPeekStoreIdentifier = @"useTapticPeek";
NSString *MBClickWidgetProgramItemShowDetail = @"clickWidgetProgramItemShowDetail";

@interface MBPrefs ()
@property (nonatomic) MMWormhole *prefsWormhole;
@end

@implementation MBPrefs

static id _instance;

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone {
    // 创建对象的步骤分为申请内存(alloc)、初始化(init)这两个步骤。在调用alloc 这一阶段时，oc内部会调用allocWithZone这个方法来申请内存，我们覆写这个方法，然后在这个方法中调用shareInstance方法返回单例对象，即可确保对象的唯一性。
    return [MBPrefs shared];
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return [MBPrefs shared];
}

- (MMWormhole *)prefsWormhole {
    if (!_prefsWormhole) {
        _prefsWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:MBAppGroupName
                                                              optionalDirectory:MBPrefsDirectoryName];
    }
    return _prefsWormhole;
}


// liveAutoRefreshInterval
- (void)setLiveAutoRefreshInterval:(MBProgramLiveAutoRefreshInterval)liveAutoRefreshInterval {
    [self.prefsWormhole passMessageObject:@(liveAutoRefreshInterval) identifier:MBProgramLiveAutoRefreshIntervalStoreIdentifier];
}

- (MBProgramLiveAutoRefreshInterval)liveAutoRefreshInterval {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBProgramLiveAutoRefreshIntervalStoreIdentifier];
    return val?[val integerValue]:MBProgramLiveAutoRefreshInterval_10s;
}

- (MBProgramLiveAutoRefreshInterval)resetLiveAutoRefreshInterval {
    MBProgramLiveAutoRefreshInterval defVal = MBProgramLiveAutoRefreshInterval_10s;
    [self setLiveAutoRefreshInterval:defVal];
    return defVal;
}

// listOperateItemsPosition
- (void)setListOperateItemsPosition:(MBProgramListOperateItemsPostion)listOperateItemsPosition {
    [self.prefsWormhole passMessageObject:@(listOperateItemsPosition) identifier:MBProgramListOperateItemsPostionStoreIdentifier];
}

- (MBProgramListOperateItemsPostion)listOperateItemsPosition {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBProgramListOperateItemsPostionStoreIdentifier];
    return val?[val integerValue]:MBProgramListOperateItemsPostionRight;
}

- (MBProgramListOperateItemsPostion)resetListOperateItemsPosition {
    MBProgramListOperateItemsPostion defVal = MBProgramListOperateItemsPostionRight;
    [self setListOperateItemsPosition:defVal];
    return defVal;
}

// listDayDateSectionHeaderFixed
- (void)setListDayDateSectionHeaderFixed:(BOOL)listDayDateSectionHeaderFixed {
    [self.prefsWormhole passMessageObject:@(listDayDateSectionHeaderFixed) identifier:MBListDayDateSectionHeaderFixedStoreIdentifier];
}

- (BOOL)listDayDateSectionHeaderFixed {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBListDayDateSectionHeaderFixedStoreIdentifier];
    return val?[val boolValue]:NO;
}

- (BOOL)resetListDayDateSectionHeaderFixed {
    BOOL defVal = NO;
    [self setListDayDateSectionHeaderFixed:defVal];
    return defVal;
}

// programRemindTime
- (void)setProgramRemindTime:(MBProgramRemindTime)programRemindTime {
    [self.prefsWormhole passMessageObject:@(programRemindTime) identifier:MBProgramRemindTimeStoreIdentifier];
}

- (MBProgramRemindTime)programRemindTime {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBProgramRemindTimeStoreIdentifier];
    return val?[val integerValue]:MBProgramRemindBefore1Min;
}

- (MBProgramRemindTime)resetProgramRemindTime {
    MBProgramRemindTime defVal = MBProgramRemindBefore1Min;
    [self setProgramRemindTime:defVal];
    return defVal;
}


// rememberLastOpenedListType
- (void)setRememberLastOpenedListType:(BOOL)rememberLastOpenedListType {
    [self.prefsWormhole passMessageObject:@(rememberLastOpenedListType) identifier:MBRememberLastOpenedListTypeStoreIdentifier];
}

- (BOOL)rememberLastOpenedListType {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBRememberLastOpenedListTypeStoreIdentifier];
    return val?[val boolValue]:YES;
}

- (BOOL)resetRememberLastOpenedListType {
    BOOL defVal = YES;
    [self setRememberLastOpenedListType:defVal];
    return defVal;
}


// lastOpenedListType
- (void)setLastOpenedListType:(NSInteger)lastOpenedListType {
    [self.prefsWormhole passMessageObject:@(lastOpenedListType) identifier:NSStringFromSelector(@selector(lastOpenedListType))];
}

- (NSInteger)lastOpenedListType {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(lastOpenedListType))];
    if (val) return [val integerValue];
    return NSNotFound;
}

// listDisplayNumInExpandedWidget
- (void)setListDisplayNumInExpandedWidget:(MBListDisplayNumInExpandedWidget)listDisplayNumInExpandedWidget {
    [self.prefsWormhole passMessageObject:@(listDisplayNumInExpandedWidget) identifier:MBListDisplayNumInExpandedWidgetStoreIdentifier];
}

- (MBListDisplayNumInExpandedWidget)listDisplayNumInExpandedWidget {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBListDisplayNumInExpandedWidgetStoreIdentifier];
    return val?[val integerValue]:MBListInExpandedWidgetDisplay3Item;
}

- (MBListDisplayNumInExpandedWidget)resetListDisplayNumInExpandedWidget {
    MBListDisplayNumInExpandedWidget defVal = MBListInExpandedWidgetDisplay3Item;
    [self setListDisplayNumInExpandedWidget:defVal];
    return defVal;
}

// useTapticPeek
- (void)setUseTapticPeek:(BOOL)useTapticPeek {
    [self.prefsWormhole passMessageObject:@(useTapticPeek) identifier:MBUseTapticPeekStoreIdentifier];
}

- (BOOL)useTapticPeek {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBUseTapticPeekStoreIdentifier];
    return val?[val boolValue]:YES;
}

- (BOOL)resetUseTapticPeek {
    BOOL defVal = YES;
    [self setUseTapticPeek:defVal];
    return defVal;
}

// clickWidgetProgramItemShowDetail
- (void)setClickWidgetProgramItemShowDetail:(BOOL)clickWidgetProgramItemShowDetail {
    [self.prefsWormhole passMessageObject:@(clickWidgetProgramItemShowDetail) identifier:MBClickWidgetProgramItemShowDetail];
}

- (BOOL)clickWidgetProgramItemShowDetail {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:MBClickWidgetProgramItemShowDetail];
    return val?[val boolValue]:YES;
}

- (BOOL)resetClickWidgetProgramItemShowDetail {
    BOOL defVal = YES;
    [self setClickWidgetProgramItemShowDetail:defVal];
    return defVal;
}

@end


@implementation UITraitCollection (MBPrefs)

- (BOOL)tapticPeekIfPossible {
    if ([MBPrefs shared].useTapticPeek) {
        return [self tapticPeekVibrate];
    }
    return NO;
}

@end
