//
//  CompactModeVC.m
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "CompactModeVC.h"
#import <MBKit/Masonry.h>
#import <MBKit/MBSpecs.h>
#import <MBKit/NSDate+TDKit.h>
#import <MBKit/NSTimer+TDKit.h>
#import "TodayProgramItemCell.h"

@interface CompactModeVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSUInteger focusedProgramNum;
@property (nonatomic) NSUInteger liveProgramNum;
@property (nonatomic) MBMatchProgram *displayProgram;

@property (nonatomic, weak) IBOutlet UIView *dataContentView;
@property (nonatomic, weak) IBOutlet UITableView *listTable;
@property (nonatomic, weak) IBOutlet UIView *seperator;
@property (nonatomic, weak) IBOutlet UIView *dataTipAnimationContainer;
@property (nonatomic, weak) IBOutlet UILabel *dataTipLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dataTipLabelLeading;
@property (nonatomic) NSTimer *dataTipLabelScrollTimer;

@property (nonatomic) NSUInteger viewDidLayoutSubviewsCallNum;

@end

@implementation CompactModeVC

- (instancetype)initWithFocusedProgramNum:(NSUInteger)focusedProgramNum
                           liveProgramNum:(NSUInteger)liveProgramNum
                           displayProgram:(MBMatchProgram *)displayProgram {
    if (self = [super initWithNibName:NSStringFromClass([CompactModeVC class]) bundle:nil]) {
        self.focusedProgramNum = focusedProgramNum;
        self.liveProgramNum = liveProgramNum;
        self.displayProgram = displayProgram;
    }
    return self;
}

- (void)scrollDataTipLabelFromOriginX:(CGFloat)fromOriginX toOriginX:(CGFloat)toOriginX {
    
    if (fromOriginX == toOriginX) return;
    
    NSTimeInterval interval = 0.2;
    // 按照滚动 100 像素点，使用 3 秒的速度进行滚动
    CGFloat moveDistance = interval*(100/4.f);
    BOOL scrollToRight = fromOriginX < toOriginX;
    
    __weak typeof(self)weakSelf = self;
    _dataTipLabelScrollTimer = [NSTimer timerWithTimeInterval:interval block:^(NSTimer *timer) {
        if (!weakSelf) {
            [timer invalidate];
            return;
        }

        CGFloat nowOriginX = weakSelf.dataTipLabelLeading.constant;
        if (scrollToRight) {
            if (nowOriginX > -toOriginX) {
                nowOriginX -= moveDistance;
                weakSelf.dataTipLabelLeading.constant = nowOriginX;
            } else {
                [timer invalidate];
                [weakSelf scrollDataTipLabelFromOriginX:-nowOriginX toOriginX:0];
            }
        } else {
            if (nowOriginX < -toOriginX){
                nowOriginX += moveDistance;
                weakSelf.dataTipLabelLeading.constant = nowOriginX;
            } else {
                [timer invalidate];
                weakSelf.dataTipLabelLeading.constant = 0;
            }
        }
        
    } repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_dataTipLabelScrollTimer forMode:NSRunLoopCommonModes];
}

- (void)updateDataTipDisplay {
    
    [_dataTipLabelScrollTimer invalidate];
    _dataTipLabelScrollTimer = nil;
    
    NSAttributedString *dataTip = [self.class constructDataTipTextWithFocusedProgramNum:self.focusedProgramNum liveProgramNum:self.liveProgramNum];
    self.dataTipLabel.attributedText = dataTip;
    self.dataTipLabelLeading.constant = 0;
    [self.dataTipAnimationContainer layoutIfNeeded];
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        CGFloat labelContainerWidth = CGRectGetWidth(weakSelf.view.frame) - 12.f*2;
        CGSize labelSize = [dataTip boundingRectWithSize:CGSizeMake(MAXFLOAT, 100) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
        if (labelSize.width > labelContainerWidth) {
            [weakSelf scrollDataTipLabelFromOriginX:0 toOriginX:(labelSize.width-labelContainerWidth)];
        }
    });
}

- (void)updateViewWithFocusedProgramNum:(NSUInteger)focusedProgramNum
                         liveProgramNum:(NSUInteger)liveProgramNum {
    if (self.focusedProgramNum != focusedProgramNum || self.liveProgramNum != liveProgramNum) {
        self.focusedProgramNum = focusedProgramNum;
        self.liveProgramNum = liveProgramNum;
        
        [self updateDataTipDisplay];
    }
}

- (void)displayProgramItemIfNeed:(MBMatchProgram *)program {
    self.displayProgram = program;
    
    [self.listTable reloadData];
}

- (BOOL)shouldDisplayData {
    return (self.focusedProgramNum + self.liveProgramNum)>0 && self.displayProgram;
}

+ (NSAttributedString *)constructDataTipTextWithFocusedProgramNum:(NSUInteger)focusedProgramNum
                                                   liveProgramNum:(NSUInteger)liveProgramNum {
    NSString *str = [NSString stringWithFormat:@"%@个关注、%@个正在直播的节目，「展开」查看更多~",@(focusedProgramNum), @(liveProgramNum)];
    NSDictionary *attrs = @{NSFontAttributeName:[MBFontSpecs small], NSForegroundColorAttributeName:[MBColorSpecs wd_minorTextColor]};
    return [[NSAttributedString alloc] initWithString:str attributes:attrs];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self.listTable registerNib:[TodayProgramItemCell nib] forCellReuseIdentifier:NSStringFromClass([TodayProgramItemCell class])];
    self.listTable.dataSource = self;
    self.listTable.delegate = self;

    self.dataTipAnimationContainer.clipsToBounds = YES;
}

- (void)dealloc {
    _dataTipLabelLeading.constant = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _dataTipLabelLeading.constant = 0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _viewDidLayoutSubviewsCallNum ++;
    if (_viewDidLayoutSubviewsCallNum == 1) {
        [self updateDataTipDisplay];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self shouldDisplayData]) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayProgramItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TodayProgramItemCell class]) forIndexPath:indexPath];
    
    MBMatchProgram *program = self.displayProgram;
    TodayProgramItemDataModel *data = [TodayProgramItemDataModel dataWithProgram:program];
    data.isFocused = [program focused];
    NSDate *progDate = [NSDate dateWithTimeIntervalSince1970:program.program_date];
    if ([progDate sameDayTo:[NSDate date]]) {
        data.startTime = [program program_daytime];
    } else {
        data.startTime = [NSString stringWithFormat:@"%@ %@",[progDate dayOfMonthAndDayOfWeekFormattedResult], [program program_daytime]?:@""];
    }
    
    [cell configureWithData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MBHeight wd_programCellHeight];
}

@end
