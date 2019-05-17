//
//  ProgramItemCellModel.h
//  matchbook
//
//  Created by guangbool on 2017/6/23.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 cell 类型

 - ProgramItemCellType_HasStarted: 节目已开始
 - ProgramItemCellType_Living: 节目正在进行
 - ProgramItemCellType_NotStart: 节目未开始
 */
typedef NS_ENUM(NSUInteger, ProgramItemCellType) {
    ProgramItemCellType_HasStarted = 0,
    ProgramItemCellType_Living,
    ProgramItemCellType_NotStart,
};

@interface ProgramItemCellModel : NSObject

// body 边距
@property (nonatomic) UIEdgeInsets bodyInset;

// cell 类型
@property (nonatomic) ProgramItemCellType cellType;

// 节目时间
@property (nonatomic, copy) NSString *daytime;

// 节目名称
@property (nonatomic, copy) NSString *programName;

// 状态
@property (nonatomic, copy) NSString *statusText;

// 主队比分
@property (nonatomic, copy) NSString *homeTeamScore;

// 主队名称
@property (nonatomic, copy) NSString *homeTeamName;

// 客队比分
@property (nonatomic, copy) NSString *visitTeamScore;

// 客队名称
@property (nonatomic, copy) NSString *visitTeamName;

// 是否已设置提醒
@property (nonatomic) BOOL hasSettedRemind;

// 是否有详情
@property (nonatomic) BOOL hasDetail;

@end
