//
//  ProgramsSectionHeader.h
//  matchbook
//
//  Created by 彭光波 on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramsSectionHeader : UITableViewHeaderFooterView

- (void)setTitleText:(NSString *)title;

+ (CGFloat)defaultHeight;

+ (CGFloat)intrinsicHeight;

@end
