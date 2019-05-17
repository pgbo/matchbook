//
//  TodayViewController.m
//  today
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <MBKit/MBPageStatusKit+MBKit.h>
#import <MBKit/MBDataController.h>
#import <MBKit/MBPrefs.h>
#import <MBKit/MBSpecs.h>
#import <MBKit/Masonry.h>
#import <MBKit/NSDate+TDKit.h>
#import <MBKit/NSTimer+TDKit.h>
#import <MBKit/NSString+TDKit.h>
#import "CompactModeVC.h"
#import "ExpandModeVC.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic) MBDataController *dataController;
// 数据是否在加载中
@property (nonatomic) BOOL isDataLoading;

@property (nonatomic) MBPageStatusKit *pageStatusKit;

/**
 节目字典。program id 作为 key, program 信息作为 value
 */
@property (nonatomic) MutableOrderedDictionary<NSString*/*program_id*/,MBMatchProgram*> *programsDictionary;

/**
 关注的节目 id 集合。
 */
@property (nonatomic) NSMutableArray<NSString*/*program_id*/> *focusedProgramIds;

/**
 正在进行直播的节目 id 集合。
 */
@property (nonatomic) NSMutableArray<NSString*/*program_id*/> *liveProgramIds;

// 加载正在进行的节目的定时器
@property (nonatomic) NSTimer *refreshLivingProgramsTimer;


// 暂无关注节目，赶快 去关注节目
@property (nonatomic) UILabel *noDataGuideLabel;
@property (nonatomic) CompactModeVC *compactModeVC;
@property (nonatomic) ExpandModeVC *expandModeVC;

@property (nonatomic) NSUInteger widgetActiveDisplayModeDidChangeCallNum;

@end

@implementation TodayViewController

- (MBDataController *)dataController {
    if (!_dataController) {
        _dataController = [[MBDataController alloc] init];
    }
    return _dataController;
}

- (MBPageStatusKit *)pageStatusKit {
    if (!_pageStatusKit) {
        _pageStatusKit = [MBPageStatusKit widgetDefaultWithContainer:self.view];
        
        __weak typeof(self)weakSelf = self;
        _pageStatusKit.noDataViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshLiveAndFocusedPrograms:nil];
        };
        
        _pageStatusKit.noNetworkViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshLiveAndFocusedPrograms:nil];
        };
        
        _pageStatusKit.normalErrorViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshLiveAndFocusedPrograms:nil];
        };
    }
    return _pageStatusKit;
}

- (MutableOrderedDictionary<NSString *,MBMatchProgram *> *)programsDictionary {
    if (!_programsDictionary) {
        _programsDictionary = [MutableOrderedDictionary<NSString *,MBMatchProgram *> dictionary];
    }
    return _programsDictionary;
}

- (NSMutableArray<NSString *> *)focusedProgramIds {
    if (!_focusedProgramIds) {
        _focusedProgramIds = [NSMutableArray<NSString *> array];
    }
    return _focusedProgramIds;
}

- (NSMutableArray<NSString *> *)liveProgramIds {
    if (!_liveProgramIds) {
        _liveProgramIds = [NSMutableArray<NSString *> array];
    }
    return _liveProgramIds;
}

- (UILabel *)noDataGuideLabel {
    if (!_noDataGuideLabel) {
        _noDataGuideLabel = [UILabel new];
        _noDataGuideLabel.numberOfLines = 0;
        _noDataGuideLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame) - 24;
        
        NSDictionary *commAttr = @{NSFontAttributeName:[MBFontSpecs regular], NSForegroundColorAttributeName:[MBColorSpecs wd_minorTextColor]};
        NSDictionary *underlineAttr = @{NSFontAttributeName:[MBFontSpecs regular], NSForegroundColorAttributeName:[MBColorSpecs wd_tint], NSUnderlineStyleAttributeName:@(1)};
        
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] init];
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:@"暂无关注节目，快去" attributes:commAttr]];
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:@"关注节目" attributes:underlineAttr]];
        
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n暂无节目正在进行，到App中" attributes:commAttr]];
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:@"查看赛程" attributes:underlineAttr]];
        
        _noDataGuideLabel.attributedText = attrText;
        
        _noDataGuideLabel.userInteractionEnabled = YES;
        [_noDataGuideLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoApp)]];
    }
    return _noDataGuideLabel;
}

- (void)gotoApp {
    [self gotoAppWithHost:nil queryString:nil];
}

- (void)gotoAppWithHost:(NSString *)host queryString:(NSString *)queryString {
    NSString *url = [NSString stringWithFormat:@"matchbook://%@?%@", host?:@"", queryString?:@""];
    [self.extensionContext openURL:[NSURL URLWithString:url] completionHandler:nil];
}

- (void)updateWidgetPreferredContentSizeIfNeed {
    
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeExpanded) {
        CGSize modeSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeExpanded];
        CGFloat height = 0;
        height += [MBPrefs shared].listDisplayNumInExpandedWidget*[MBHeight wd_programCellHeight];
        height += 44;
        modeSize.height = height;
        self.preferredContentSize = modeSize;
    } else {
        CGSize modeSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact];
        self.preferredContentSize = modeSize;
    }
}

+ (NSDate *)todayDate {
    return [[NSDate date] sameDayWithHour:0 minute:0 second:0];
}

- (MBDCRefreshProgramsInDayRequest *)createRefreshRequestWithStartFromDay:(NSDate *)startFromDay {
    MBDCRefreshProgramsInDayRequest *info = [MBDCRefreshProgramsInDayRequest new];
    info.returnListType = MBDataControllerMatchList_Focus|MBDataControllerMatchList_Living;
    info.startFromDay = startFromDay?:[self.class todayDate];
    info.minimumNum = 50;
    info.days = 7;
    return info;
}

- (void)updateViewsIfNeedWithCompleteHandler:(void(^)())completeHandler {
    
    // Dismiss all present vcs
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (self.isDataLoading) {
        [_pageStatusKit hide];
        [self.pageStatusKit showLoading];
        if (completeHandler) {
            completeHandler();
        }
        return;
    } else {
        // Load data
        __weak typeof(self)weakSelf = self;
        [self loadLiveAndFocusedPrograms:^{
            [weakSelf displayDataWithCompletion:completeHandler];
        }];
    }
}


/**
 找到合适的节目，用于compact模式下显示。优先找关注并正在直播的，其次着关注的，最后找直播中的
 */
- (MBMatchProgram *)findSuitableProgramDisplayInCompactMode {
    OrderedDictionary<NSString*,MBMatchProgram*> *programs = [_programsDictionary copy];
    NSArray<NSString*> *focusedIds = [_focusedProgramIds copy];
    NSArray<NSString*> *liveIds = [_liveProgramIds copy];
    
    NSUInteger firstLocation = NSIntegerMax;
    NSUInteger lastLocation = 0;
    
    if (focusedIds.count > 0) {
        NSUInteger firstLoc = [programs.allKeys indexOfObject:focusedIds.firstObject];
        if (firstLoc != NSNotFound) firstLocation = MIN(firstLocation, firstLoc);
        NSUInteger lastLoc = [programs.allKeys indexOfObject:focusedIds.lastObject];
        if (lastLoc != NSNotFound) lastLocation = MAX(lastLocation, lastLoc);
    }
    
    if (liveIds.count > 0) {
        NSUInteger firstLoc = [programs.allKeys indexOfObject:liveIds.firstObject];
        if (firstLoc != NSNotFound) firstLocation = MIN(firstLocation, firstLoc);
        NSUInteger lastLoc = [programs.allKeys indexOfObject:liveIds.lastObject];
        if (lastLoc != NSNotFound) lastLocation = MAX(lastLocation, lastLoc);;
    }
    
    if (lastLocation < firstLocation) {
        return nil;
    }
    
    MBMatchProgram *focusedAndLiveItem = nil;
    for (NSUInteger i = firstLocation; i <= lastLocation; i++) {
        MBMatchProgram *prog = programs.allValues[i];
        if (prog.focused && (prog.is_living > 0)) {
            focusedAndLiveItem = prog;
            break;
        }
    }
    
    if (focusedAndLiveItem) return focusedAndLiveItem;
    
    MBMatchProgram *tarProg = [self findMostRecentProgramInIds:focusedIds];
    if (tarProg) return tarProg;
    
    tarProg = [self findMostRecentProgramInIds:liveIds];
    
    return tarProg;
}

- (MBMatchProgram *)findMostRecentProgramInIds:(NSArray<NSString*>*)ids {
    if (ids.count == 0) return nil;
    OrderedDictionary<NSString *,MBMatchProgram *> *programs = [self.programsDictionary copy];
    
    NSDate *nowDate = [NSDate date];
    NSUInteger nowTimestamp = [nowDate timeIntervalSince1970];
    
    NSInteger minInterval = -1;
    MBMatchProgram *tarProg = nil;
    for (NSString *_id in ids) {
        MBMatchProgram *prog = programs[_id];
        if (!prog) continue;
        NSUInteger interval = (NSUInteger)abs((int)(prog.program_date - nowTimestamp));
        if (minInterval > interval) {
            minInterval = interval;
            tarProg = prog;
        }
    }
    
    return tarProg;
}

- (void)displayDataWithCompletion:(void(^)())completion {
    
    // Dismiss all presented vcs before present a new one
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // 根据数据显示视图
    if ((self.focusedProgramIds.count + self.liveProgramIds.count) == 0) {
        // 无数据的情况
        self.noDataGuideLabel.hidden = NO;
        if (completion) completion();
    } else {
        // 有数据情况
        self.noDataGuideLabel.hidden = YES;
        
        // Present relative vc to display datas
        if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
            
            // Init compactModeVC
            // 找到合适的节目，用于显示。
            MBMatchProgram *displayProg = [self findSuitableProgramDisplayInCompactMode];
            self.compactModeVC = [[CompactModeVC alloc] initWithFocusedProgramNum:self.focusedProgramIds.count liveProgramNum:self.liveProgramIds.count displayProgram:displayProg];
            
            [self presentViewController:self.compactModeVC animated:NO completion:completion];
            
        } else {
            
            // Init expandModeVC
            
            self.expandModeVC = [[ExpandModeVC alloc] initWithAllPrograms:self.programsDictionary.allValues];
            __weak typeof(self)weakSelf = self;
            self.expandModeVC.moreBlock = ^(ExpandModeVC *vc) {
                [weakSelf gotoApp];
            };
            self.expandModeVC.programDidSelectedBlock = ^(ExpandModeVC *vc, MBMatchProgram *program) {
                NSString *detailUrl = program.detail_link;
                if ([MBPrefs shared].clickWidgetProgramItemShowDetail
                    && detailUrl.length > 0) {
                    NSString *queryString = [NSString stringWithFormat:@"link=%@", [detailUrl stringByURLEncode]];
                    [weakSelf gotoAppWithHost:@"detail" queryString:queryString];
                }
            };
            
            [self presentViewController:self.expandModeVC animated:NO completion:completion];
        }
    }
}

- (void)widgetActiveDisplayModeDidChangeWhenInitial {
    // do nothing
}

- (void)widgetActiveDisplayModeDidChangeByManual {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    // dismiss all presented view controllers
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // update widget content size
    [self updateWidgetPreferredContentSizeIfNeed];
    
    // present relative vc to display data
    [self displayDataWithCompletion:nil];
}

- (void)refreshLiveAndFocusedPrograms:(void(^)())completion {
    
    if (_isDataLoading) return;
    self.isDataLoading = YES;
    
    [self stopRefreshLivingProgramsTimer];
    
    [_pageStatusKit hide];
    [self.pageStatusKit showLoading];
    __weak typeof(self)weakSelf = self;
    [self.dataController refreshProgramsInDay:[self createRefreshRequestWithStartFromDay:nil] handler:^(MBDCRefreshProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        
        // Clear datas
        [strongSelf.programsDictionary removeAllObjects];
        [strongSelf.focusedProgramIds removeAllObjects];
        [strongSelf.liveProgramIds removeAllObjects];
        
        if (status == MBQueryMatchInfoNoNetwork) {
            [strongSelf.pageStatusKit showNoNetwork];
            if (completion) completion();
            return;
        }
        if (status == MBQueryMatchInfoFail) {
            [strongSelf.pageStatusKit showNormalError];
            if (completion) completion();
            return;
        }
        
        [strongSelf.pageStatusKit hide];
        
        [returnn.dayProgramSets.allValues enumerateObjectsUsingBlock:^(NSArray<MBMatchProgram*> *dayPrograms, NSUInteger idx, BOOL *stop) {
            for (MBMatchProgram *prog in dayPrograms) {
                NSString *program_id = prog.program_id;
                if (program_id.length == 0) continue;
                
                // Add into 'programsDictionary'
                strongSelf.programsDictionary[program_id] = prog;
            
                // Add into 'focusedProgramIds' if need
                if (prog.focused) {
                    [strongSelf.focusedProgramIds addObject:program_id];
                }
                
                // Add into 'liveProgramIds' if need
                if (prog.is_living > 0) {
                    [strongSelf.liveProgramIds addObject:program_id];
                }
            }
        }];
        
        [strongSelf startRefreshLivingProgramsTimerIfNeed];
        
        [strongSelf displayDataWithCompletion:completion];
    }];
}

- (void)loadLiveAndFocusedPrograms:(void(^)())completion {
    
    if (_isDataLoading) return;
    self.isDataLoading = YES;
    
    [self stopRefreshLivingProgramsTimer];
    
    [_pageStatusKit hide];
    [self.pageStatusKit showLoading];
    
    __weak typeof(self)weakSelf = self;
    [self.dataController loadProgramsInDay:({
        
        MBDCLoadProgramsInDayRequest *info = [MBDCLoadProgramsInDayRequest new];
        info.listType = MBDataControllerMatchList_Focus|MBDataControllerMatchList_Living;
        info.startFromDay = [self.class todayDate];
        info.minimumNum = 50;
        info.days = 7;
        info.forwardQuery = YES;
        info.loadNewestLivingState = YES;
        info.refreshInfoWhenNeedRefresh = [weakSelf createRefreshRequestWithStartFromDay:info.startFromDay];
        
        info;
        
    }) handler:^(MBDCLoadProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        
        // Clear datas
        [strongSelf.programsDictionary removeAllObjects];
        [strongSelf.focusedProgramIds removeAllObjects];
        [strongSelf.liveProgramIds removeAllObjects];
        
        if (status == MBQueryMatchInfoNoNetwork) {
            [strongSelf.pageStatusKit showNoNetwork];
            if (completion) completion();
            return;
        }
        if (status == MBQueryMatchInfoFail) {
            [strongSelf.pageStatusKit showNormalError];
            if (completion) completion();
            return;
        }
        
        [strongSelf.pageStatusKit hide];
        
        [returnn.dayProgramSets.allValues enumerateObjectsUsingBlock:^(NSArray<MBMatchProgram*> *dayPrograms, NSUInteger idx, BOOL *stop) {
            for (MBMatchProgram *prog in dayPrograms) {
                NSString *program_id = prog.program_id;
                if (program_id.length == 0) continue;
                
                // Add into 'programsDictionary'
                strongSelf.programsDictionary[program_id] = prog;
                
                // Add into 'focusedProgramIds' if need
                if (prog.focused) {
                    [strongSelf.focusedProgramIds addObject:program_id];
                }
                
                // Add into 'liveProgramIds' if need
                if (prog.is_living > 0) {
                    [strongSelf.liveProgramIds addObject:program_id];
                }
            }
        }];
        
        [weakSelf startRefreshLivingProgramsTimerIfNeed];
        
        if (completion) {
            completion();
        }
    }];
}

- (void)startRefreshLivingProgramsTimerIfNeed {
    if (_programsDictionary.count == 0) return;
    
    [_refreshLivingProgramsTimer invalidate];
    _refreshLivingProgramsTimer = nil;
    
    MBProgramLiveAutoRefreshInterval refreshInterval = [MBPrefs shared].liveAutoRefreshInterval;
    if (refreshInterval != MBProgramLiveNotAutoRefresh && refreshInterval > 0) {
        __weak typeof(self)weakSelf = self;
        _refreshLivingProgramsTimer = [NSTimer timerWithTimeInterval:refreshInterval block:^(NSTimer *timer) {
            // Execute code when timer firing.
            [weakSelf refreshAllLivingProgramsIfNeed];
        } repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_refreshLivingProgramsTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopRefreshLivingProgramsTimer {
    [_refreshLivingProgramsTimer invalidate];
    _refreshLivingProgramsTimer = nil;
}

- (void)refreshAllLivingProgramsIfNeed {
    if (self.isDataLoading) return;
    
    __weak typeof(self)weakSelf = self;
    [self.dataController refreshAllLivingProgramList:^(NSArray<MBMatchProgram *> *results,
                                                       MBQueryMatchInfoStatus status,
                                                       NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf.isDataLoading) return;
        if (status != MBQueryMatchInfoSuccess) return;
        
        
        // Update old living rows to 'Finished' state
        MutableOrderedDictionary *programsDict = [strongSelf.programsDictionary copy];
        NSMutableArray<NSString*> *oldLiveProgramIds = [strongSelf.liveProgramIds copy];
        
        [oldLiveProgramIds enumerateObjectsUsingBlock:^(NSString *_id, NSUInteger idx, BOOL *stop) {
            MBMatchProgram *prog = programsDict[_id];
            // Update to 'Finished' state
            prog.is_living = 0;
        }];
        
        // Clear living records
        [strongSelf.liveProgramIds removeAllObjects];
        
        
        // Update new living rows
        NSMutableArray<MBMatchProgram *> *livePrograms = [NSMutableArray array];
        [results enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {
            NSString *_id = obj.program_id;
            NSUInteger existIdx = [programsDict.allKeys indexOfObject:_id];
            if (existIdx != NSNotFound) {
                MBMatchProgram *oldProg = programsDict[_id];
                [oldProg fillPropertiesWithAnother:obj ignoreUnkownValueFields:YES];
                if (oldProg.is_living > 0) {
                    // Add into living
                    [strongSelf.liveProgramIds addObject:_id];
                    [livePrograms addObject:oldProg];
                }
            }
        }];
        
        // Refresh data display if need
        if (strongSelf.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeExpanded) {
            [strongSelf.expandModeVC refreshLivePrograms:livePrograms];
        } else {
            [strongSelf.compactModeVC updateViewWithFocusedProgramNum:strongSelf.focusedProgramIds.count liveProgramNum:strongSelf.liveProgramIds.count];
            [strongSelf.compactModeVC displayProgramItemIfNeed:[strongSelf findSuitableProgramDisplayInCompactMode]];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    self.noDataGuideLabel.hidden = YES;
    [self.view addSubview:self.noDataGuideLabel];
    [self.noDataGuideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _noDataGuideLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame) - 24;
}


#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self updateWidgetPreferredContentSizeIfNeed];
    
    [self updateViewsIfNeedWithCompleteHandler:^{
        if (completionHandler) {
            completionHandler(NCUpdateResultNewData);
        }
    }];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    self.widgetActiveDisplayModeDidChangeCallNum ++;
    if (self.widgetActiveDisplayModeDidChangeCallNum == 1) {
        // 第一次自动调用该方法
        [self widgetActiveDisplayModeDidChangeWhenInitial];
    } else {
        // 手动改变 widget 模式
        [self widgetActiveDisplayModeDidChangeByManual];
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

@end
