//
//  ProgramItemTableCell.m
//  matchbook
//
//  Created by guangbool on 2017/6/22.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ProgramItemTableCell.h"
#import <MBKit/UIImage+TDKit.h>
#import <MBKit/MBSpecs.h>
#import "UIImage+MBApp.h"
#import "UIImage+MBBundle.h"

static const CGFloat ProgramItemCellBodyWrapperHeight = 104.f;

@interface ProgramItemTableCell ()

@property (nonatomic, weak) IBOutlet UIView *bodyWrapper;
@property (nonatomic, weak) IBOutlet UILabel *daytimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *programNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *livingMarkView;
@property (nonatomic, weak) IBOutlet UIButton *homeTeamScoreView;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *visitTeamScoreView;
@property (nonatomic, weak) IBOutlet UILabel *visitTeamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *hasSetRemindLabel;
@property (nonatomic, weak) IBOutlet UIImageView *remindImageView;
@property (nonatomic, weak) IBOutlet UIButton *toggleRemindButn;
@property (nonatomic, weak) IBOutlet UIButton *detailButn;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bodyLeading;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bodyTrailing;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bodyTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *homeTeamLabelLeading;

@property (nonatomic, strong) ProgramItemCellModel *data;

@end

@implementation ProgramItemTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureViews];
}

- (void)configureViews {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.livingMarkView setBackgroundImage:[UIImage liveMarkViewBackgroudImage] forState:UIControlStateDisabled];
    
    [self.homeTeamScoreView setBackgroundImage:[UIImage homeTeamScoreViewBackgroudImage] forState:UIControlStateDisabled];
    [self.visitTeamScoreView setBackgroundImage:[UIImage visitTeamScoreViewBackgroudImage] forState:UIControlStateDisabled];
    
    [self.detailButn setBackgroundImage:[UIImage nornalPositiveBorderTransparentRoundedButtonBackgroudImage] forState:UIControlStateNormal];
    
    [self.toggleRemindButn addTarget:self
                              action:@selector(toggleRemind:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.detailButn addTarget:self
                        action:@selector(detail:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleRemind:(id)sender {
    if (self.toggleReminderBlock) {
        self.toggleReminderBlock(self);
    }
}

- (void)detail:(id)sender {
    if (self.detailBlock) {
        self.detailBlock(self);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets bodyInset = self.data.bodyInset;
    return CGSizeMake(size.width,
                      ProgramItemCellBodyWrapperHeight + bodyInset.top + bodyInset.bottom);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([ProgramItemTableCell class])
                          bundle:[NSBundle bundleForClass:[ProgramItemTableCell class]]];
}

+ (NSString *)reuseIdentifierWithCellType:(ProgramItemCellType)cellType {
    return [NSString stringWithFormat:@"%@_celltype_%@",
            NSStringFromClass([ProgramItemTableCell class]),
            @(cellType)];
}

- (void)configureWithData:(ProgramItemCellModel *)data {
    
    self.data = data;
    
    self.bodyLeading.constant = data.bodyInset.left;
    self.bodyTrailing.constant = data.bodyInset.right;
    self.bodyTop.constant = data.bodyInset.top;
    
    if (data.cellType == ProgramItemCellType_NotStart) {
        self.livingMarkView.hidden = YES;
        self.homeTeamScoreView.hidden = YES;
        self.visitTeamScoreView.hidden = YES;
        
        self.homeTeamLabelLeading.constant = 12;
        
        if (data.hasSettedRemind) {
            self.hasSetRemindLabel.hidden = NO;
            self.remindImageView.hidden = YES;
            [self.toggleRemindButn setTitle:@"取消提醒" forState:UIControlStateNormal];
            [self.toggleRemindButn setTitleColor:[MBColorSpecs app_passiveTint] forState:UIControlStateNormal];
            [self.toggleRemindButn setBackgroundImage:[UIImage passiveBorderTransparentRoundedButtonBackgroudImage] forState:UIControlStateNormal];
        } else {
            self.hasSetRemindLabel.hidden = YES;
            self.remindImageView.hidden = NO;
            [self.toggleRemindButn setTitle:@"设置提醒" forState:UIControlStateNormal];
            [self.toggleRemindButn setTitleColor:[MBColorSpecs app_mainPositiveTint] forState:UIControlStateNormal];
            [self.toggleRemindButn setBackgroundImage:nil forState:UIControlStateNormal];
        }
        
        self.toggleRemindButn.hidden = NO;
        
    } else {
        
        if (data.cellType == ProgramItemCellType_Living) {
            self.livingMarkView.hidden = NO;
        } else if (data.cellType == ProgramItemCellType_HasStarted){
            self.livingMarkView.hidden = YES;
        }
        
        self.homeTeamScoreView.hidden = NO;
        self.visitTeamScoreView.hidden = NO;
        self.homeTeamLabelLeading.constant = 58;
        
        if (data.hasSettedRemind) {
            self.hasSetRemindLabel.hidden = NO;
            self.remindImageView.hidden = YES;
            self.toggleRemindButn.hidden = NO;
            [self.toggleRemindButn setTitle:@"取消关注" forState:UIControlStateNormal];
            [self.toggleRemindButn setTitleColor:[MBColorSpecs app_passiveTint] forState:UIControlStateNormal];
            [self.toggleRemindButn setBackgroundImage:[UIImage passiveBorderTransparentRoundedButtonBackgroudImage] forState:UIControlStateNormal];
        } else {
            self.hasSetRemindLabel.hidden = YES;
            self.remindImageView.hidden = YES;
            self.toggleRemindButn.hidden = YES;
        }
    }
    
    self.daytimeLabel.text = data.daytime;
    self.programNameLabel.text = data.programName;
    
    if (data.statusText.length > 0 && data.cellType != ProgramItemCellType_Living) {
        self.statusLabel.text = data.statusText;
    } else {
        self.statusLabel.text = nil;
    }
    
    NSString *homeScore = data.homeTeamScore.length>0?data.homeTeamScore:@"-";
    NSString *visitScore = data.visitTeamScore.length>0?data.visitTeamScore:@"-";
    NSString *homeTeamName = data.homeTeamName.length>0?data.homeTeamName:@"-";
    NSString *visitTeamName = data.visitTeamName.length>0?data.visitTeamName:@"-";
    [self.homeTeamScoreView setTitle:homeScore forState:UIControlStateDisabled];
    self.homeTeamNameLabel.text = homeTeamName;
    [self.visitTeamScoreView setTitle:visitScore forState:UIControlStateDisabled];
    self.visitTeamNameLabel.text = visitTeamName;
    
    self.detailButn.hidden = !data.hasDetail;
}

+ (CGFloat)cellHeightWithBodyInset:(UIEdgeInsets)bodyInset {
    return (ProgramItemCellBodyWrapperHeight + bodyInset.top + bodyInset.bottom);
}

@end
