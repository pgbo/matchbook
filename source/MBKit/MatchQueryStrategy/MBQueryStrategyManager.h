//
//  MBQueryStrategyManager.h
//  matchbook
//
//  Created by guangbool on 2017/6/16.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBQueryStrategy.h"

@interface MBQueryStrategyManager : NSObject <MBQueryStrategy>

// 节目查询策略配置信息
@property (nonatomic, readonly) NSDictionary *config;

/**
 配置信息更新 handler。
 通过方法`updateConfig:`改变config 不会调用该回调。
 */
@property (nonatomic, copy) void(^configChangedHandler)(NSDictionary *newConfig);

/**
 主动更新节目查询策略配置信息

 @param newConfig 新的配置信息
 */
- (void)updateConfig:(NSDictionary *)newConfig;

/**
 获取最新配置信息。
 返回的字典可以通过 MBQueryStrategyMacros 中的 MBQueryStrategyConfigKey__ 系列 key 进行获取

 @param async   是否异步，在异步时通过回调handler返回结果，否则方法直接返回结果
 @param handler 结果处理
 */
+ (NSDictionary *)loadNewestConfigWithAsync:(BOOL)async handler:(void(^)(NSDictionary *config))handler;

@end
