//
//  MBQueryStrategy.h
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBMatchProgram.h"
#import "MBQueryRequests.h"

typedef NS_ENUM(NSUInteger, MBQueryMatchInfoStatus) {
    MBQueryMatchInfoSuccess = 0,
    MBQueryMatchInfoNoNetwork,
    MBQueryMatchInfoFail,
};

typedef void(^MBQueryMatchListCompleteHandler)(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider);

typedef void(^MBQueryLivingMatchesCompleteHandler)(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider);

typedef void(^MBQueryMatchInfoCompleteHandler)(MBMatchProgram *result, MBQueryMatchInfoStatus status, NSString *serviceProvider);

@protocol MBQueryStrategy <NSObject>

@optional
/**
 根据配置初始化

 @param config 配置
 @return 初始化结果
 */
+ (instancetype)strategyWithConfig:(NSDictionary *)config;

/**
 查询所有比赛列表
 
 @param reqInfo 请求信息
 @param handler handler
 */
- (void)queryMatchList:(MBQueryMatchListRequest *)reqInfo
               handler:(MBQueryMatchListCompleteHandler)handler;


/**
 查询正在进行的比赛节目

 @param handler handler
 */
- (void)queryLivingMatchesWithHandler:(MBQueryLivingMatchesCompleteHandler)handler;


/**
 查询某个比赛信息

 @param requestInfoBlock 请求信息获取 block，不同的策略实现可能需要的请求信息不一样
 @param handler handler
 */
- (void)queryMatchInfo:(NSDictionary<NSString*,
                        NSString*>*(^)(NSString *strategyImplCode))requestInfoBlock
               handler:(MBQueryMatchInfoCompleteHandler)handler;

@end
