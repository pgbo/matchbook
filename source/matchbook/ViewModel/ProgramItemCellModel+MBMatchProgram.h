//
//  ProgramItemCellModel+MBMatchProgram.h
//  matchbook
//
//  Created by guangbool on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ProgramItemCellModel.h"
#import <MBKit/MBMatchProgram.h>

@interface ProgramItemCellModel (MBMatchProgram)

+ (ProgramItemCellModel *)modelWithProgram:(MBMatchProgram *)program
                          currentTimestamp:(NSTimeInterval)currentTimestamp;

@end
