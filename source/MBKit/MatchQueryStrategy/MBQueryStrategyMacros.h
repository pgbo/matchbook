//
//  MBQueryStrategyMacros.h
//  matchbook
//
//  Created by guangbool on 2017/6/16.
//  Copyright © 2017年 devbool. All rights reserved.
//

#ifndef MBQueryStrategyMacros_h
#define MBQueryStrategyMacros_h

// 版本，每次更新配置信息时，版本号都要变更，一般情况下+1就可以
#define MBQueryStrategyConfigKey__version @"version"
// 策略实现方式的编号
#define MBQueryStrategyConfigKey__strategy_impl_code @"strategy_impl_code"
// 获取所有比赛列表的 url
#define MBQueryStrategyConfigKey__query_matches_url @"query_matches_url"
// 获取正在进行的比赛的 url
#define MBQueryStrategyConfigKey__query_processing_matches_url @"query_processing_matches_url"
// 获取某个比赛信息的 url
#define MBQueryStrategyConfigKey__query_match_info_url @"query_match_info_url"
// 解析数据的脚本 url
#define MBQueryStrategyConfigKey__data_parse_js_url @"data_parse_js_url"
// 比赛列表更新的间隔时间（单位:小时）
#define MBQueryStrategyConfigKey__matches_update_interval_hours @"matches_update_interval_hours"

// 已知的策略实现方式编号: zb8
#define MBQueryStrategy_ZB8QueryImplCode @"zb8"

#endif /* MBQueryStrategyMacros_h */
