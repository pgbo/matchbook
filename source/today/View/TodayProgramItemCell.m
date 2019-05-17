//
//  TodayProgramItemCell.m
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "TodayProgramItemCell.h"
#import <MBKit/UIImage+TDKit.h>
#import <MBKit/MBSpecs.h>
#import "UIImage+MBBundle.h"

@interface TodayProgramItemCell ()

@property (nonatomic, weak) IBOutlet UIView *topSeparator;
@property (nonatomic, weak) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *programNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *focusedMarkView;
@property (nonatomic, weak) IBOutlet UIButton *livingMarkView;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *homeTeamScoreView;
@property (nonatomic, weak) IBOutlet UIButton *visitTeamScoreView;
@property (nonatomic, weak) IBOutlet UILabel *visitTeamNameLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *focusedMarkWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *focusedMarkRightSpacing;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *liveMarkWidth;

@property (nonatomic) TodayProgramItemDataModel *data;

@end

@implementation TodayProgramItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureViews];
}

- (void)configureViews {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.focusedMarkView setBackgroundImage:[UIImage focusedMarkViewBackgroudImage] forState:UIControlStateDisabled];
    [self.livingMarkView setBackgroundImage:[UIImage liveMarkViewBackgroudImage] forState:UIControlStateDisabled];
    
    [self.homeTeamScoreView setBackgroundImage:[UIImage homeTeamScoreViewBackgroudImage] forState:UIControlStateDisabled];
    [self.visitTeamScoreView setBackgroundImage:[UIImage visitTeamScoreViewBackgroudImage] forState:UIControlStateDisabled];
    
    [self setShowTopSeparator:NO];
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([TodayProgramItemCell class]) bundle:[NSBundle bundleForClass:[TodayProgramItemCell class]]];
}

- (void)setShowTopSeparator:(BOOL)showTopSeparator {
    _showTopSeparator = showTopSeparator;
    self.topSeparator.hidden = !showTopSeparator;
}

- (void)configureWithData:(TodayProgramItemDataModel *)data {
    
    self.data = data;
    
    if (data.isFocused) {
        self.focusedMarkView.hidden = NO;
        self.focusedMarkWidth.constant = 40;
    } else {
        self.focusedMarkView.hidden = YES;
        self.focusedMarkWidth.constant = 0;
    }
    
    if (data.isLiving) {
        self.focusedMarkRightSpacing.constant = 0;
        self.livingMarkView.hidden = NO;
        self.liveMarkWidth.constant = 40;
    } else {
        self.focusedMarkRightSpacing.constant = 0;
        self.livingMarkView.hidden = YES;
        self.liveMarkWidth.constant = 0;
    }
    
    self.startTimeLabel.text = data.startTime;
    self.programNameLabel.text = data.programName;
    
    NSString *homeScore = data.homeTeamScore.length>0?data.homeTeamScore:@"-";
    NSString *visitScore = data.visitTeamScore.length>0?data.visitTeamScore:@"-";
    
    NSString *homeTeamName = data.homeTeamName.length>0?data.homeTeamName:@"-";
    NSString *visitTeamName = data.visitTeamName.length>0?data.visitTeamName:@"-";
   
    self.homeTeamNameLabel.text = homeTeamName;
   
    [self.homeTeamScoreView setTitle:homeScore forState:UIControlStateDisabled];
    
    [self.visitTeamScoreView setTitle:visitScore forState:UIControlStateDisabled];
    
    self.visitTeamNameLabel.text = visitTeamName;
}

@end

@implementation TodayProgramItemDataModel

+ (TodayProgramItemDataModel *)dataWithProgram:(MBMatchProgram *)program {
    TodayProgramItemDataModel *info = [TodayProgramItemDataModel new];
    
    info.isLiving = (program.is_living > 0);
    info.startTime = program.program_daytime;
    info.programName = program.program_name;
    info.homeTeamName = program.participants.firstObject;
    info.visitTeamName = program.participants.count>1?program.participants[1]:nil;
    info.homeTeamScore = program.scores.firstObject;
    info.visitTeamScore = program.scores.count>1?program.scores[1]:nil;
    
    return info;
}

@end
