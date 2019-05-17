//
//  MBMatchProgram.h
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBMatchProgram : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *detail_link;
@property (nonatomic, copy) NSString *program_id;        	// eg: 99711
@property (nonatomic) NSInteger program_date;               // timestamp
@property (nonatomic, copy) NSString *program_daytime;   	// eg: 19:30（HH:mm）
@property (nonatomic, copy) NSString *program_name;			// eg: 天下足球，足球热身赛
@property (nonatomic, copy) NSArray<NSString*> *participants; // eg: ["荷兰", "中国"]
@property (nonatomic) NSInteger is_important;               // 是否重要。 -1 表示未知，0 为NO，1 为YES。默认 -1
@property (nonatomic) NSInteger is_football;                // 是否是足球。 -1 表示未知，0 为NO，1 为YES。默认 -1
@property (nonatomic) NSInteger is_basketball;              // 是否是篮球。 -1 表示未知，0 为NO，1 为YES。默认 -1
@property (nonatomic, copy) NSString *status;               // 状态, eg: 未开始，进行中，已结束
@property (nonatomic) NSInteger is_living;                  // 是否正在进行中。 -1 表示未知，0 为NO，1 为YES。默认 -1
@property (nonatomic, copy) NSArray<NSString *> *scores;	// 比分, eg: ["100", "88"], Array<string>

- (instancetype)initWithDictiotnary:(NSDictionary *)dictionary;


/**
 通过另一个实例来填充自身的属性

 @param anotherObj 另一个实例
 @param ignoreUnkownValueFields 是否忽略值为未知（nil或未知标示值）的属性
 */
- (void)fillPropertiesWithAnother:(MBMatchProgram *)anotherObj
                ignoreUnkownValueFields:(BOOL)ignoreUnkownValueFields;

@end
