//
//  TodayProgramItemCell.h
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBKit/MBMatchProgram.h>
@class TodayProgramItemDataModel;

@interface TodayProgramItemCell : UITableViewCell

@property (nonatomic, readonly) TodayProgramItemDataModel *data;

// 是否显示顶部分割线
@property (nonatomic, assign) BOOL showTopSeparator;


/**
 获取 nib 对象
 
 @return result
 */
+ (UINib *)nib;

/**
 配置 cell
 
 @param data 数据
 */
- (void)configureWithData:(TodayProgramItemDataModel *)data;

@end


@interface TodayProgramItemDataModel : NSObject

// 是否直播中
@property (nonatomic) BOOL isLiving;

// 是否被关注
@property (nonatomic) BOOL isFocused;

// 节目时间
@property (nonatomic, copy) NSString *startTime;

// 节目名称
@property (nonatomic, copy) NSString *programName;

// 主队比分
@property (nonatomic, copy) NSString *homeTeamScore;

// 主队名称
@property (nonatomic, copy) NSString *homeTeamName;

// 客队比分
@property (nonatomic, copy) NSString *visitTeamScore;

// 客队名称
@property (nonatomic, copy) NSString *visitTeamName;

+ (TodayProgramItemDataModel *)dataWithProgram:(MBMatchProgram *)program;

@end
