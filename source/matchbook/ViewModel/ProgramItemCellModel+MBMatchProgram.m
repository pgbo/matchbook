//
//  ProgramItemCellModel+MBMatchProgram.m
//  matchbook
//
//  Created by guangbool on 2017/6/24.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ProgramItemCellModel+MBMatchProgram.h"

@implementation ProgramItemCellModel (MBMatchProgram)

+ (ProgramItemCellModel *)modelWithProgram:(MBMatchProgram *)program
                          currentTimestamp:(NSTimeInterval)currentTimestamp {
    ProgramItemCellModel *data = [[ProgramItemCellModel alloc] init];
    
    if (program.is_living > 0) {
        data.cellType = ProgramItemCellType_Living;
    } else if (currentTimestamp > program.program_date) {
        data.cellType = ProgramItemCellType_HasStarted;
    } else {
        data.cellType =  ProgramItemCellType_NotStart;
    }
    
    data.daytime = program.program_daytime;
    data.programName = program.program_name;
    data.statusText = program.status;
    
    {
        data.homeTeamScore = program.scores.firstObject;
        data.homeTeamName = program.participants.firstObject;
        data.visitTeamScore = program.scores.count>1?program.scores[1]:nil;
        data.visitTeamName = program.participants.count>1?program.participants[1]:nil;
    }
    
    data.hasDetail = program.detail_link.length>0;
    
    return data;
}

@end
