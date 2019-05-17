//
//  ProgramItemTableCell.h
//  matchbook
//
//  Created by guangbool on 2017/6/22.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgramItemCellModel.h"

@interface ProgramItemTableCell : UITableViewCell


/**
 添加或取消提醒 block
 */
@property (nonatomic, copy) void(^toggleReminderBlock)(ProgramItemTableCell *cell);

/**
 详情 block
 */
@property (nonatomic, copy) void(^detailBlock)(ProgramItemTableCell *cell);


@property (nonatomic, readonly) ProgramItemCellModel *data;


/**
 获取 nib 对象

 @return result
 */
+ (UINib *)nib;


/**
 获取 reuseIdentifier

 @param cellType cell 类型
 @return result
 */
+ (NSString *)reuseIdentifierWithCellType:(ProgramItemCellType)cellType;


/**
 配置 cell

 @param data 数据
 */
- (void)configureWithData:(ProgramItemCellModel *)data;


/**
  计算高度

 @param bodyInset body的边距
 @return 结果
 */
+ (CGFloat)cellHeightWithBodyInset:(UIEdgeInsets)bodyInset;

@end
