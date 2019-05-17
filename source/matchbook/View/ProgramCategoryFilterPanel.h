//
//  ProgramCategoryFilterPanel.h
//  matchbook
//
//  Created by guangbool on 2017/6/26.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramCategoryFilterPanel : UIView

@property (nonatomic, copy) NSArray<NSString *> *categories;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, copy) void(^categoryDidSelected)(ProgramCategoryFilterPanel *panel, NSUInteger idx);

// 最大本身高度
@property (nonatomic, assign) CGFloat maxIntrinsicContentHeight;

- (CGSize)intrinsicContentSize;

@end
