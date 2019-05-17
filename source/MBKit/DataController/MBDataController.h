//
//  MBDataController.h
//  matchbook
//
//  Created by guangbool on 2017/6/20.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBQueryStrategy.h"
#import "Reachability.h"
#import "OrderedDictionary.h"

typedef NS_OPTIONS(NSUInteger, MBDataControllerMatchListType) {
    MBDataControllerMatchList_All           = 1 << 0,   // 全部
    MBDataControllerMatchList_Important     = 1 << 1,   // 重要
    MBDataControllerMatchList_Football      = 1 << 2,   // 足球
    MBDataControllerMatchList_Basketball    = 1 << 3,   // 篮球
    MBDataControllerMatchList_Focus         = 1 << 4,   // 关注
    MBDataControllerMatchList_Living        = 1 << 5,   // 正在进行中的比赛节目
};

@class MBDCRefreshProgramListRequest;
@class MBDCLoadProgramListRequest;

@class MBDCLoadProgramsInDayRequest;
@class MBDCLoadProgramsInDayReturn;
@class MBDCRefreshProgramsInDayRequest;
@class MBDCRefreshProgramsInDayReturn;

/**
 加载节目列表的结果处理 handler 定义

 @param resultsReferProgramId 返回的结果列表参考的节目 id，调用者根据该值决定如何处理页面，比如为 nil 时刷新界面上的列表，不为 nil 时则添加界面上的列表行
 @param results 具体结果集合
 @param status 状态
 @param serviceProvider 服务提供者
 */
typedef void(^MBDCLoadProgramListHandler)(  NSString                    *resultsReferProgramId,
                                            NSArray<MBMatchProgram *>   *results,
                                            MBQueryMatchInfoStatus      status,
                                            NSString                    *serviceProvider);

typedef void(^MBDCLoadProgramsInDayHandler)(MBDCLoadProgramsInDayReturn *returnn,
                                            MBQueryMatchInfoStatus status,
                                            NSString *serviceProvider);

typedef void(^MBDCRefreshProgramsInDayHandler)( MBDCRefreshProgramsInDayReturn *returnn,
                                                MBQueryMatchInfoStatus status,
                                                NSString *serviceProvider);

@interface MBDataController : NSObject

- (instancetype)initWithReachability:(Reachability *)reachability;

/**
 刷新比赛节目列表，并返回请求信息指定的列表
 
 @param request 请求信息
 @param handler 结果处理
 */
- (void)refreshProgramList:(MBDCRefreshProgramListRequest *)request
                   handler:(MBQueryMatchListCompleteHandler)handler;

/**
 加载比赛节目列表

 @param request 请求信息
 @param handler 结果处理
 */
- (void)loadProgramList:(MBDCLoadProgramListRequest *)request
                handler:(MBDCLoadProgramListHandler)handler;


/**
 查询所有正在进行的节目列表

 @param handler 结果处理
 */
- (void)refreshAllLivingProgramList:(MBQueryMatchListCompleteHandler)handler;

/**
 添加提醒

 @param programId 节目 id
 @param handler 结果处理
 */
- (void)addRemindForProgramWithId:(NSString *)programId handler:(void(^)(BOOL success))handler;

/**
 删除提醒
 
 @param programId 节目 id
 @param handler 结果处理
 */
- (void)removeRemindForProgramWithId:(NSString *)programId handler:(void(^)(BOOL success))handler;


/**
 刷新节目，并返回对应请求的结果
 
 @param request 请求信息
 @param handler 结果处理
 */
- (void)refreshProgramsInDay:(MBDCRefreshProgramsInDayRequest *)request
                     handler:(MBDCRefreshProgramsInDayHandler)handler;

/**
 按天查询节目

 @param request 请求信息
 @param handler 结果处理
 */
- (void)loadProgramsInDay:(MBDCLoadProgramsInDayRequest *)request
                  handler:(MBDCLoadProgramsInDayHandler)handler;

@end

@interface MBDCRefreshProgramListRequest : NSObject

// 返回的列表类型
@property (nonatomic, assign) MBDataControllerMatchListType returnListType;
// 返回的列表大小，正数表示向后查询，负数表示向前查询，不能为 0
@property (nonatomic, assign) NSInteger pageSize;
// 返回的列表从'正在进行的'的节目开始
@property (nonatomic, assign) BOOL listBeginFromLiving;

@end

@interface MBDCLoadProgramListRequest : NSObject

// 列表类型
@property (nonatomic, assign) MBDataControllerMatchListType type;
// 参考 id
@property (nonatomic, copy) NSString *referProgramId;
// 返回的列表大小，正数表示向后查询，负数表示向前查询，不能为 0
@property (nonatomic, assign) NSInteger pageSize;
// 在'参考id'不可用时，返回的列表从'正在进行的'的节目开始
@property (nonatomic, assign) BOOL listBeginFromLivingWhenReferIdUnavailable;

@end

@interface MBMatchProgram (MBDataController)

// 是否关注
@property (nonatomic, assign) BOOL focused;

@end


@interface MBDCRefreshProgramsInDayRequest : NSObject

/**
 返回的列表类型
 */
@property (nonatomic, assign) MBDataControllerMatchListType returnListType;

/**
 查询的开始当天日期（返回的结果包括该日的节目）
 */
@property (nonatomic, assign) NSDate *startFromDay;

/**
 返回的节目最小数目限定。0 表示不限定
 */
@property (nonatomic, assign) NSUInteger minimumNum;

/**
 根据参考日期向后查询的天数。
 */
@property (nonatomic, assign) NSUInteger days;

@end

@interface MBDCRefreshProgramsInDayReturn : NSObject

/**
 以某天为 key、该天的所有节目为 value 的字典查询结果
 */
@property (nonatomic, copy) OrderedDictionary<NSDate *, NSArray<MBMatchProgram*>*> *dayProgramSets;

@end


@interface MBDCLoadProgramsInDayRequest : NSObject

/**
 查询列表类型
 */
@property (nonatomic, assign) MBDataControllerMatchListType listType;

/**
 查询的开始当天日期（返回的结果包括该日的节目）
 */
@property (nonatomic, copy) NSDate *startFromDay;

/**
 返回的节目最小数目限定。0 表示不限定
 */
@property (nonatomic, assign) NSUInteger minimumNum;

/**
 根据参考日期向后或向前查询的天数。
 */
@property (nonatomic, assign) NSUInteger days;

/**
 是否正向查询。否则为负向查询
 */
@property (nonatomic, assign) BOOL forwardQuery;

/**
  是否要查询节目的最新播出状态
 */
@property (nonatomic, assign) BOOL loadNewestLivingState;

/**
 当需要刷新时，刷新的请求信息
 */
@property (nonatomic) MBDCRefreshProgramsInDayRequest *refreshInfoWhenNeedRefresh;

@end


@interface MBDCLoadProgramsInDayReturn : NSObject

/**
 是否应该刷新
 */
@property (nonatomic, assign) BOOL needRefresh;

/**
 以某天为 key、该天的所有节目为 value 的字典查询结果
 */
@property (nonatomic, copy) OrderedDictionary<NSDate *, NSArray<MBMatchProgram*>*> *dayProgramSets;

@end
