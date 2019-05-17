//
//  MainViewController.m
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MainViewController.h"
#import <MBKit/MBKit.h>
#import <UIButton-SSEdgeInsets/UIButton+SSEdgeInsets.h>
#import <SafariServices/SafariServices.h>
#import "ProgramItemTableCell.h"
#import "ProgramItemCellModel+MBMatchProgram.h"
#import "ProgramsSectionHeader.h"
#import "ProgramCategoryFilterPanel.h"
#import "TDOverlayDrawAnimation.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

static NSString *const MainViewControllerListSectionHeader = @"MainViewControllerListSectionHeader";
static OrderedDictionary<NSNumber*,NSString*> *MainViewControllerCategories = nil;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIButton *categoryFilterButnTitleView;
@property (nonatomic) UIBarButtonItem *settingBarItem;
@property (nonatomic) UIBarButtonItem *closeCategoryFilterPanelBarItem;
@property (nonatomic) UIView *categoryFilterPanelOverlayView;
@property (nonatomic) ProgramCategoryFilterPanel *categoryFilterPanel;
@property (nonatomic) UIButton *positionToLivingButn;
@property (nonatomic) UIButton *refreshButn;

@property (nonatomic) MBDataControllerMatchListType listType;
@property (nonatomic) MBDataController *dataController;
// 数据是否在加载中
@property (nonatomic) BOOL isDataLoading;

@property (nonatomic) MBPageStatusKit *pageStatusKit;
@property (nonatomic) MBRefreshKit *pageupKit;
@property (nonatomic) MBLoadMoreKit *loadMoreKit;

@property (nonatomic) MMWormhole *prefsWormhole;

/**
 类目下某些天所进行节目集合。
 日期当天为key，该日的节目集合作为 value
 */
@property (nonatomic) MutableOrderedDictionary<NSDate*,
                                               MutableOrderedDictionary<NSString*/*program_id*/,MBMatchProgram*>*>
                                               *dayDateAndProgramsDictionary;


/**
 某些天所有正在进行的节目集合
 日期当天为key，该日所进行节目集合作为 value
 */
@property (nonatomic) MutableOrderedDictionary<NSDate*,
                                               NSMutableArray<NSString*/*program_id*/>*>
                                               *dayAndLivingIdsDictionary;


/**
 数据是否来自于刷新，否则来自于加载本地
 */
@property (nonatomic) BOOL isDataFromRefresh;

// 更新当前时间的定时器
@property (nonatomic) UIBackgroundTaskIdentifier updateNowTimeTimerBackgroundTask;
@property (nonatomic) NSTimer *updateNowTimeTimer;
@property (nonatomic) NSTimeInterval nowTimestamp;

// 加载正在进行的节目的定时器
@property (nonatomic) UIBackgroundTaskIdentifier refreshLivingProgramsTimerBackgroundTask;
@property (nonatomic) NSTimer *refreshLivingProgramsTimer;

@property (nonatomic) NSUInteger viewDidLayoutSubviewsCallNum;

@end

@implementation MainViewController

+ (void)initialize {
    
    MutableOrderedDictionary *categories = [MutableOrderedDictionary dictionary];
    categories[@(MBDataControllerMatchList_All)] = @"全部";
    categories[@(MBDataControllerMatchList_Important)] = @"重要";
    categories[@(MBDataControllerMatchList_Football)] = @"足球";
    categories[@(MBDataControllerMatchList_Basketball)] = @"篮球";
    categories[@(MBDataControllerMatchList_Focus)] = @"关注";
    
    MainViewControllerCategories = [categories copy];
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableViewStyle style = [MBPrefs shared].listDayDateSectionHeaderFixed?UITableViewStylePlain:UITableViewStyleGrouped;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) style:style];
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[ProgramItemTableCell nib]
             forCellReuseIdentifier:[ProgramItemTableCell reuseIdentifierWithCellType:ProgramItemCellType_HasStarted]];
        [_tableView registerNib:[ProgramItemTableCell nib]
             forCellReuseIdentifier:[ProgramItemTableCell reuseIdentifierWithCellType:ProgramItemCellType_Living]];
        [_tableView registerNib:[ProgramItemTableCell nib]
             forCellReuseIdentifier:[ProgramItemTableCell reuseIdentifierWithCellType:ProgramItemCellType_NotStart]];
        [_tableView registerClass:[ProgramsSectionHeader class] forHeaderFooterViewReuseIdentifier:MainViewControllerListSectionHeader];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIButton *)categoryFilterButnTitleView {
    if (!_categoryFilterButnTitleView) {
        UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
        [butn setImage:[UIImage imageNamed:@"dropdown_arrow_ic"] forState:UIControlStateNormal];
        [butn setImage:[UIImage imageNamed:@"dropdown_arrow_ic"] forState:UIControlStateHighlighted];
        [butn setTitleColor:[MBColorSpecs app_navigationText] forState:UIControlStateNormal];
        butn.titleLabel.font = [MBFontSpecs largeBold];
        [butn setTitle:MainViewControllerCategories[@(self.listType)] forState:UIControlStateNormal];
        [butn setImagePositionWithType:SSImagePositionTypeRight spacing:6];
        butn.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 64*2, 44);
//        [butn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(CGRectGetWidth([UIScreen mainScreen].bounds) - 64*2);
//        }];
        [butn addTarget:self action:@selector(showCategoryFilterPanel) forControlEvents:UIControlEventTouchUpInside];
        _categoryFilterButnTitleView = butn;
    }
    return _categoryFilterButnTitleView;
}

- (UIBarButtonItem *)settingBarItem {
    if (!_settingBarItem) {
        _settingBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_ic"] style:UIBarButtonItemStylePlain target:self action:@selector(navToSettings)];
    }
    return _settingBarItem;
}

- (UIBarButtonItem *)closeCategoryFilterPanelBarItem {
    if (!_closeCategoryFilterPanelBarItem) {
        _closeCategoryFilterPanelBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_ic"] style:UIBarButtonItemStylePlain target:self action:@selector(hideCategoryFilterPanel)];
    }
    return _closeCategoryFilterPanelBarItem;
}

- (UIView *)categoryFilterPanelOverlayView {
    if (!_categoryFilterPanelOverlayView) {
        _categoryFilterPanelOverlayView = [UIControl new];
        _categoryFilterPanelOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [((UIControl *)_categoryFilterPanelOverlayView) addTarget:self action:@selector(hideCategoryFilterPanel) forControlEvents:UIControlEventTouchDown];
    }
    return _categoryFilterPanelOverlayView;
}

- (ProgramCategoryFilterPanel *)categoryFilterPanel {
    if (!_categoryFilterPanel) {
        ProgramCategoryFilterPanel *panel = [[ProgramCategoryFilterPanel alloc] initWithFrame:[UIScreen mainScreen].bounds];
        panel.selectedIndex = [MainViewControllerCategories.allKeys indexOfObject:@(self.listType)];
        panel.categories = MainViewControllerCategories.allValues;
        __weak typeof(self)weakSelf = self;
        panel.categoryDidSelected = ^(ProgramCategoryFilterPanel *panel, NSUInteger idx) {
            [weakSelf hideCategoryFilterPanel];

            MBDataControllerMatchListType orignType = weakSelf.listType;
            MBDataControllerMatchListType newType = MainViewControllerCategories.allKeys[idx].integerValue;
            if (orignType != newType) {
                // Update listType
                [weakSelf setListType:newType];
                
                NSString *title = MainViewControllerCategories[@(newType)];
                [weakSelf.categoryFilterButnTitleView setTitle:title
                                                      forState:UIControlStateNormal];
                [weakSelf.categoryFilterButnTitleView setImagePositionWithType:SSImagePositionTypeRight spacing:6];
                [weakSelf loadFirstPageProgramList];
            }
        };
        _categoryFilterPanel = panel;
    }
    return _categoryFilterPanel;
}

- (UIButton *)positionToLivingButn {
    if (!_positionToLivingButn) {
        _positionToLivingButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_positionToLivingButn setImage:[UIImage imageNamed:@"scroll_up_to_living_ic"] forState:UIControlStateNormal];
        [_positionToLivingButn addTarget:self
                                  action:@selector(positionToLivig)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    return _positionToLivingButn;
}

- (UIButton *)refreshButn {
    if (!_refreshButn) {
        _refreshButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButn setImage:[UIImage imageNamed:@"refresh_ic"] forState:UIControlStateNormal];
        [_refreshButn addTarget:self action:@selector(refreshProgramList) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButn;
}

- (MBDataController *)dataController {
    if (!_dataController) {
        _dataController = [[MBDataController alloc] initWithReachability:[AppDelegate instance].reachability];
    }
    return _dataController;
}

- (MBPageStatusKit *)pageStatusKit {
    if (!_pageStatusKit) {
        _pageStatusKit = [MBPageStatusKit appDefaultWithContainer:self.view];
        
        __weak typeof(self)weakSelf = self;
        _pageStatusKit.noDataViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshProgramList];
        };
        
        _pageStatusKit.noNetworkViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshProgramList];
        };
        
        _pageStatusKit.normalErrorViewTouchBlock = ^(MBPageStatusKit *kit) {
            [weakSelf refreshProgramList];
        };
    }
    return _pageStatusKit;
}

- (void)installPageupKitOrNot:(BOOL)installOrNot {
    if (installOrNot) {
        [self.pageupKit installToScrollView:self.tableView];
    } else {
        [_pageupKit uninstall];
    }
}

- (MBRefreshKit *)pageupKit {
    if (!_pageupKit) {
        __weak typeof(self)weakSelf = self;
        _pageupKit = [MBRefreshKit PageupKitWithActionBlock:^(MBRefreshKit *kit){
            [weakSelf loadPreviousProgramList];
        }];
    }
    return _pageupKit;
}

- (void)installLoadMoreKitOrNot:(BOOL)installOrNot {
    if (installOrNot) {
        [self.loadMoreKit installToScrollView:self.tableView];
    } else {
        [_loadMoreKit uninstall];
    }
}

- (MBLoadMoreKit *)loadMoreKit {
    if (!_loadMoreKit) {
        __weak typeof(self)weakSelf = self;
        _loadMoreKit = [MBLoadMoreKit defaultLoadMoreKitWithActionBlock:^(MBLoadMoreKit *kit){
            [weakSelf loadMoreProgramList];
        }];
    }
    return _loadMoreKit;
}

- (MMWormhole *)prefsWormhole {
    if (!_prefsWormhole) {
        _prefsWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:MBAppGroupName
                                                              optionalDirectory:MBPrefsDirectoryName];
    }
    return _prefsWormhole;
}

- (MutableOrderedDictionary<NSDate*,MutableOrderedDictionary<NSString*,MBMatchProgram*>*> *)dayDateAndProgramsDictionary {
    if (!_dayDateAndProgramsDictionary) {
        _dayDateAndProgramsDictionary = [MutableOrderedDictionary<NSDate*,MutableOrderedDictionary<NSString*,MBMatchProgram*> *> dictionary];
    }
    return _dayDateAndProgramsDictionary;
}

- (MutableOrderedDictionary<NSDate*,NSMutableArray<NSString*>*>*)dayAndLivingIdsDictionary {
    if (!_dayAndLivingIdsDictionary) {
        _dayAndLivingIdsDictionary = [MutableOrderedDictionary<NSDate*,NSMutableArray<NSString*>*> dictionary];
    }
    return _dayAndLivingIdsDictionary;
}

- (CGFloat)categoryFilterPanelTopSpacing {
    CGFloat topSpacing = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        topSpacing = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    return topSpacing;
}

- (CGSize)categoryFilterPanelAnimationContainerSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, screenSize.height - [self categoryFilterPanelTopSpacing]);
}

- (void)showCategoryFilterPanel {
    if (self.isDataLoading) return;
    
    if (!self.categoryFilterPanelOverlayView.superview) {
        [self.view addSubview:self.categoryFilterPanelOverlayView];
    }
    CGFloat panelTopSpacing = [self categoryFilterPanelTopSpacing];
    __weak typeof(self)weakSelf = self;
    [self.categoryFilterPanelOverlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).offset(panelTopSpacing);
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.equalTo(weakSelf.mas_bottomLayoutGuide);
    }];
    [self.view bringSubviewToFront:self.categoryFilterPanelOverlayView];
    
    if (!self.categoryFilterPanel.superview) {
        [self.categoryFilterPanelOverlayView addSubview:self.categoryFilterPanel];
    }
    self.categoryFilterPanel.maxIntrinsicContentHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - panelTopSpacing;
    [self.categoryFilterPanel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    
    [self.view layoutIfNeeded];
    
    // Store interactivePopGestureRecognizer state
    [self setAssociateValue:@(self.navigationController.interactivePopGestureRecognizer.enabled) withKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"];
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromTop;
    drawAnimation.drawView = self.categoryFilterPanel;
    drawAnimation.overlayBackgroudView = self.categoryFilterPanelOverlayView;
    drawAnimation.animationContainerSize = [self categoryFilterPanelAnimationContainerSize];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = NO;
        ctx.toVisible = YES;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            self.navigationItem.titleView = nil;
            self.navigationItem.title = @"请选择";
            self.navigationItem.rightBarButtonItem = [self closeCategoryFilterPanelBarItem];

            // Set interactivePopGestureRecognizer disabled
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        };
        ctx;
    })];
}

- (void)hideCategoryFilterPanel {
    if (!_categoryFilterPanel && !_categoryFilterPanelOverlayView) {
        return;
    }
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromTop;
    drawAnimation.drawView = _categoryFilterPanel;
    drawAnimation.overlayBackgroudView = _categoryFilterPanelOverlayView;
    drawAnimation.animationContainerSize = [self categoryFilterPanelAnimationContainerSize];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = YES;
        ctx.toVisible = NO;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            self.navigationItem.title = nil;
            self.navigationItem.titleView = [self categoryFilterButnTitleView];
            self.navigationItem.rightBarButtonItem = [self settingBarItem];
            
            // Restore interactivePopGestureRecognizer state
            self.navigationController.interactivePopGestureRecognizer.enabled = ((NSNumber *)[self getAssociatedValueForKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"]).boolValue;
        };
        ctx;
    })];
}


/**
 Update listType and do some other things.

 @param listType new listType
 */
- (void)setListType:(MBDataControllerMatchListType)listType {
    _listType = listType;
    
    // Remember last opened list type if need
    if ([MBPrefs shared].rememberLastOpenedListType) {
        [MBPrefs shared].lastOpenedListType = listType;
    }
}

- (NSIndexPath *)findFisrtLivingProgramIndexPath {
    OrderedDictionary<NSDate*,MutableOrderedDictionary<NSString*,MBMatchProgram*>*> *dayAndProgramsDict = [self.dayDateAndProgramsDictionary copy];
    if (dayAndProgramsDict.count == 0) return nil;
    
    OrderedDictionary<NSDate*,NSMutableArray<NSString*>*> *dayAndLivingIdsDict = [self.dayAndLivingIdsDictionary copy];
    if (dayAndLivingIdsDict.count == 0) return nil;
    
    __block NSDate *firstLivingDay = nil;
    __block NSString *firstLivingProgramId = nil;
    [dayAndLivingIdsDict enumerateKeysAndObjectsWithIndexUsingBlock:^(NSDate *key,
                                                                      NSMutableArray<NSString *> *obj,
                                                                      NSUInteger idx,
                                                                      BOOL *stop) {
        if (obj.count > 0) {
            firstLivingDay = key;
            firstLivingProgramId = obj.firstObject;
            *stop = YES;
        }
    }];
    
    if (!firstLivingDay || !firstLivingProgramId) return nil;
    
    NSUInteger tarSectionIdx = [dayAndProgramsDict.allKeys indexOfObject:firstLivingDay];
    if (tarSectionIdx == NSNotFound) return nil;
    NSUInteger tarRowIdx = [dayAndProgramsDict.allValues[tarSectionIdx].allKeys indexOfObject:firstLivingProgramId];
    if (tarRowIdx == NSNotFound) tarRowIdx = 0;
    
    return [NSIndexPath indexPathForRow:tarRowIdx inSection:tarSectionIdx];
}

/**
 距离现在时间最近的比赛所在 indexpath
 
 @return result
 */
- (NSIndexPath *)findMostRecentProgramIndexPath {
    OrderedDictionary<NSDate*,MutableOrderedDictionary<NSString*,MBMatchProgram*>*> *dayAndProgramsDict = [self.dayDateAndProgramsDictionary copy];
    if (dayAndProgramsDict.count == 0) return nil;
    
    NSDate *nowDate = [NSDate date];
    NSDate *todayDay = [nowDate sameDayWithHour:0 minute:0 second:0];
    NSUInteger tarSectionIdx = [dayAndProgramsDict.allKeys indexOfObject:todayDay];
    if (tarSectionIdx != NSNotFound) {
        NSArray<MBMatchProgram*> *programs = dayAndProgramsDict.allValues[tarSectionIdx].allValues;
        if (programs.count > 0) {
            __block NSInteger minInterval = -1;
            __block NSUInteger tarRow = NSNotFound;
            NSUInteger nowTimestamp = [nowDate timeIntervalSince1970];
            [programs enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {
                NSUInteger interval = (NSUInteger)abs((int)(obj.program_date - nowTimestamp));
                if (minInterval > interval) {
                    minInterval = interval;
                    tarRow = idx;
                }
            }];
            if (tarRow != NSNotFound) {
                return [NSIndexPath indexPathForRow:tarRow inSection:tarSectionIdx];
            }
        }
    }
    return nil;
}

- (void)updateListOperateItemsPosition {
    [_refreshButn mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([MBPrefs shared].listOperateItemsPosition == MBProgramListOperateItemsPostionRight) {
            make.trailing.mas_equalTo(-16);
        } else {
            make.leading.mas_equalTo(16);
        }
        make.bottom.mas_equalTo(-30);
    }];
}

- (void)resetTableView {
    [_tableView removeFromSuperview];
    [_pageupKit uninstall];
    [_loadMoreKit uninstall];
    _tableView = nil;
    
    // reset table
    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)positionToLivig {
    if (self.isDataLoading) return;
    
    NSIndexPath *tarPositionIndexPath = [self findFisrtLivingProgramIndexPath];
    if (!tarPositionIndexPath) {
        tarPositionIndexPath = [self findMostRecentProgramIndexPath];
    }
    
    if (tarPositionIndexPath) {
        
        [self.tableView scrollToRowAtIndexPath:tarPositionIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

+ (NSDate *)todayDate {
    return [[NSDate date] sameDayWithHour:0 minute:0 second:0];
}

- (MBDCRefreshProgramsInDayRequest *)createDefaultRefreshRequest {
    MBDCRefreshProgramsInDayRequest *info = [MBDCRefreshProgramsInDayRequest new];
    info.returnListType = self.listType;
    info.startFromDay = [self.class todayDate];
    info.minimumNum = 20;
    info.days = 2;
    return info;
}

- (void)refreshProgramList {
    
    if (_isDataLoading) return;
    self.isDataLoading = YES;
    
    [self endBackgroundTaskForUpdateNowTimeTimer];
    [self stopUpdateNowTimeTimer];
    [self endBackgroundTaskForRefreshLivingProgramsTimer];
    [self stopRefreshLivingProgramsTimer];
    
    [_pageupKit uninstall];
    [_loadMoreKit uninstall];
    [self.dayDateAndProgramsDictionary removeAllObjects];
    [self.dayAndLivingIdsDictionary removeAllObjects];
    [self.tableView reloadData];
    
    self.refreshButn.hidden = YES;
    self.positionToLivingButn.hidden = YES;
    
    [self.pageStatusKit showLoading];
    __weak typeof(self)weakSelf = self;
    [self.dataController refreshProgramsInDay:[self createDefaultRefreshRequest] handler:^(MBDCRefreshProgramsInDayReturn *returnn,
                 MBQueryMatchInfoStatus status,
                 NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        strongSelf.isDataFromRefresh = YES;
        
        if (status == MBQueryMatchInfoNoNetwork) {
            [strongSelf.pageStatusKit showNoNetwork];
            return;
        }
        if (status == MBQueryMatchInfoFail) {
            [strongSelf.pageStatusKit showNormalError];
            return;
        }
        
        if (!returnn || returnn.dayProgramSets.count == 0) {
            [strongSelf.pageStatusKit showNoData];
            return;
        }
        
        [strongSelf.pageStatusKit hide];
        
        // Clear datas
        [strongSelf.dayAndLivingIdsDictionary removeAllObjects];
        [strongSelf.dayDateAndProgramsDictionary removeAllObjects];
        
        [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                     NSUInteger idx,
                                                                     BOOL *stop) {
            MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
            if (!dictsInSection) {
                dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
            }
            strongSelf.dayDateAndProgramsDictionary[dateKey] = dictsInSection;
            
            NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
            [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                dictsInSection[prog.program_id] = prog;
                if (prog.is_living > 0) {
                    // Add into living
                    NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                    if (!livingsInDay) {
                        livingsInDay = [NSMutableArray array];
                        strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                    }
                    [livingsInDay removeObject:prog.program_id];
                    [livingsInDay addObject:prog.program_id];
                }
            }];
        }];
        
        // Reload table data
        [strongSelf.tableView reloadData];
        [strongSelf.pageupKit installToScrollView:strongSelf.tableView];
        [strongSelf.loadMoreKit installToScrollView:strongSelf.tableView];
        
        strongSelf.refreshButn.hidden = NO;
        strongSelf.positionToLivingButn.hidden = NO;
        
        // Posttion to living
        [strongSelf positionToLivig];
        
        [strongSelf startUpdateNowTimeTimerIfNeed];
        [strongSelf registerBackgroundTaskForUpdateNowTimeTimer];
        [strongSelf startRefreshLivingProgramsTimerIfNeed];
        [strongSelf registerBackgroundTaskForRefreshLivingProgramsTimer];
    }];
}

- (void)loadFirstPageProgramList {
    
    if (_isDataLoading) return;
    self.isDataLoading = YES;
    
    [self endBackgroundTaskForUpdateNowTimeTimer];
    [self stopUpdateNowTimeTimer];
    [self endBackgroundTaskForRefreshLivingProgramsTimer];
    [self stopRefreshLivingProgramsTimer];
    
    [_pageupKit uninstall];
    [_loadMoreKit uninstall];
    [self.dayDateAndProgramsDictionary removeAllObjects];
    [self.dayAndLivingIdsDictionary removeAllObjects];
    [self.tableView reloadData];
    
    self.refreshButn.hidden = YES;
    self.positionToLivingButn.hidden = YES;
    
    [self.pageStatusKit showLoading];
    __weak typeof(self)weakSelf = self;
    [self.dataController loadProgramsInDay:({
        MBDCLoadProgramsInDayRequest *info = [MBDCLoadProgramsInDayRequest new];
        info.listType = weakSelf.listType;
        info.startFromDay = [weakSelf.class todayDate];
        info.minimumNum = 20;
        info.days = 2;
        info.forwardQuery = YES;
        info.loadNewestLivingState = YES;
        info.refreshInfoWhenNeedRefresh = [weakSelf createDefaultRefreshRequest];
        info;
    }) handler:^(MBDCLoadProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        strongSelf.isDataFromRefresh = returnn.needRefresh;
        
        if (status == MBQueryMatchInfoNoNetwork) {
            [strongSelf.pageStatusKit showNoNetwork];
            return;
        }
        if (status == MBQueryMatchInfoFail) {
            [strongSelf.pageStatusKit showNormalError];
            return;
        }
        
        if (!returnn || returnn.dayProgramSets.count == 0) {
            [strongSelf.pageStatusKit showNoData];
            return;
        }
        
        [strongSelf.pageStatusKit hide];
        
        // Clear datas
        [strongSelf.dayAndLivingIdsDictionary removeAllObjects];
        [strongSelf.dayDateAndProgramsDictionary removeAllObjects];
        
        [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                     NSUInteger idx,
                                                                     BOOL *stop) {
            MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
            if (!dictsInSection) {
                dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
            }
            strongSelf.dayDateAndProgramsDictionary[dateKey] = dictsInSection;
            
            NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
            [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                dictsInSection[prog.program_id] = prog;
                if (prog.is_living > 0) {
                    // Add into living
                    NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                    if (!livingsInDay) {
                        livingsInDay = [NSMutableArray array];
                        strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                    }
                    [livingsInDay removeObject:prog.program_id];
                    [livingsInDay addObject:prog.program_id];
                }
            }];
        }];
        
        // Reload table data
        [strongSelf.tableView reloadData];
        [strongSelf.pageupKit installToScrollView:strongSelf.tableView];
        [strongSelf.loadMoreKit installToScrollView:strongSelf.tableView];

        strongSelf.refreshButn.hidden = NO;
        strongSelf.positionToLivingButn.hidden = NO;
        
        // Posttion to living
        [strongSelf positionToLivig];
        
        [strongSelf startUpdateNowTimeTimerIfNeed];
        [strongSelf registerBackgroundTaskForUpdateNowTimeTimer];
        [strongSelf startRefreshLivingProgramsTimerIfNeed];
        [strongSelf registerBackgroundTaskForRefreshLivingProgramsTimer];
    }];
}

- (void)loadPreviousProgramList {
    
    if (_isDataLoading) {
        [_pageupKit finishRefreshing];
        return;
    }
    if (self.dayDateAndProgramsDictionary.count == 0) {
        // Empty list, won't use load previous action
        [_pageupKit finishRefreshing];
        return;
    }
    self.isDataLoading = YES;
    
    [self endBackgroundTaskForUpdateNowTimeTimer];
    [self stopUpdateNowTimeTimer];
    [self endBackgroundTaskForRefreshLivingProgramsTimer];
    [self stopRefreshLivingProgramsTimer];
    
    
    self.refreshButn.hidden = YES;
    self.positionToLivingButn.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    NSDate *startFromDay = [self.dayDateAndProgramsDictionary.allKeys.firstObject dateByAddingDays:-1];
    [self.dataController loadProgramsInDay:({
        MBDCLoadProgramsInDayRequest *info = [MBDCLoadProgramsInDayRequest new];
        info.listType = weakSelf.listType;
        info.startFromDay = startFromDay;
        info.minimumNum = 20;
        info.days = 2;
        info.forwardQuery = NO;
        info.loadNewestLivingState = YES;
        info.refreshInfoWhenNeedRefresh = [weakSelf createDefaultRefreshRequest];
        info;
    }) handler:^(MBDCLoadProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        [strongSelf.pageupKit finishRefreshing];
        strongSelf.isDataFromRefresh = returnn.needRefresh;
        
        if (returnn.needRefresh) {
            // Clear datas
            [strongSelf.dayAndLivingIdsDictionary removeAllObjects];
            [strongSelf.dayDateAndProgramsDictionary removeAllObjects];
            
            if (returnn.dayProgramSets.count > 0) {
                // Need refresh data
                
                [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                             NSUInteger idx,
                                                                             BOOL *stop) {
                    MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
                    if (!dictsInSection) {
                        dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
                    }
                    strongSelf.dayDateAndProgramsDictionary[dateKey] = dictsInSection;
                    
                    NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
                    [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                        dictsInSection[prog.program_id] = prog;
                        if (prog.is_living > 0) {
                            // Add into living
                            NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                            if (!livingsInDay) {
                                livingsInDay = [NSMutableArray array];
                                strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                            }
                            [livingsInDay removeObject:prog.program_id];
                            [livingsInDay addObject:prog.program_id];
                        }
                    }];
                }];
                
                // Reload table data
                [strongSelf.tableView reloadData];
                [strongSelf installPageupKitOrNot:YES];
                [strongSelf installLoadMoreKitOrNot:YES];
                
                // Posttion to living
                [strongSelf positionToLivig];
                
            } else {
                // Reload table data
                [strongSelf.tableView reloadData];
                [strongSelf installPageupKitOrNot:NO];
                [strongSelf installLoadMoreKitOrNot:NO];
                [strongSelf.pageStatusKit showNoData];
            }
            
        } else {
            
            // Insert new items
            __block NSUInteger insertSectionNum = 0;
            [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                         NSUInteger idx,
                                                                         BOOL *stop) {
                MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
                if (!dictsInSection) {
                    dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
                    [strongSelf.dayDateAndProgramsDictionary insertObject:dictsInSection
                                                                   forKey:dateKey
                                                                  atIndex:0];
                    insertSectionNum ++;
                }
                
                NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
                [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                    dictsInSection[prog.program_id] = prog;
                    if (prog.is_living > 0) {
                        // Add into living
                        NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                        if (!livingsInDay) {
                            livingsInDay = [NSMutableArray array];
                            strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                        }
                        [livingsInDay removeObject:prog.program_id];
                        [livingsInDay addObject:prog.program_id];
                    }
                }];
            }];
            
            if (insertSectionNum > 0) {
                NSIndexSet *insertSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertSectionNum)];
                [strongSelf.tableView beginUpdates];
                [strongSelf.tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationFade];
                [strongSelf.tableView endUpdates];
                [strongSelf installLoadMoreKitOrNot:YES];
            }
        }
        
        strongSelf.refreshButn.hidden = NO;
        strongSelf.positionToLivingButn.hidden = NO;
        
        [strongSelf startUpdateNowTimeTimerIfNeed];
        [strongSelf registerBackgroundTaskForUpdateNowTimeTimer];
        [strongSelf startRefreshLivingProgramsTimerIfNeed];
        [strongSelf registerBackgroundTaskForRefreshLivingProgramsTimer];
    }];
}

- (void)loadMoreProgramList {
    
    if (_isDataLoading) {
        [_loadMoreKit finishLoading];
        return;
    }
    if (self.dayDateAndProgramsDictionary.count == 0) {
        // Empty list, won't use load previous action
        [_loadMoreKit finishLoading];
        return;
    }
    self.isDataLoading = YES;
    
    [self endBackgroundTaskForUpdateNowTimeTimer];
    [self stopUpdateNowTimeTimer];
    [self endBackgroundTaskForRefreshLivingProgramsTimer];
    [self stopRefreshLivingProgramsTimer];
    
    
    self.refreshButn.hidden = YES;
    self.positionToLivingButn.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    NSDate *startFromDay = [self.dayDateAndProgramsDictionary.allKeys.lastObject dateByAddingDays:1];
    [self.dataController loadProgramsInDay:({
        MBDCLoadProgramsInDayRequest *info = [MBDCLoadProgramsInDayRequest new];
        info.listType = weakSelf.listType;
        info.startFromDay = startFromDay;
        info.minimumNum = 20;
        info.days = 2;
        info.forwardQuery = YES;
        info.loadNewestLivingState = YES;
        info.refreshInfoWhenNeedRefresh = [weakSelf createDefaultRefreshRequest];
        info;
    }) handler:^(MBDCLoadProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isDataLoading = NO;
        [strongSelf.loadMoreKit finishLoading];
        strongSelf.isDataFromRefresh = returnn.needRefresh;
        
        
        if (returnn.needRefresh) {
            // Clear datas
            [strongSelf.dayAndLivingIdsDictionary removeAllObjects];
            [strongSelf.dayDateAndProgramsDictionary removeAllObjects];
            
            if (returnn.dayProgramSets.count > 0) {
                // Need refresh data
                
                [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                             NSUInteger idx,
                                                                             BOOL *stop) {
                    MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
                    if (!dictsInSection) {
                        dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
                    }
                    strongSelf.dayDateAndProgramsDictionary[dateKey] = dictsInSection;
                    
                    NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
                    [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                        dictsInSection[prog.program_id] = prog;
                        if (prog.is_living > 0) {
                            // Add into living
                            NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                            if (!livingsInDay) {
                                livingsInDay = [NSMutableArray array];
                                strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                            }
                            [livingsInDay removeObject:prog.program_id];
                            [livingsInDay addObject:prog.program_id];
                        }
                    }];
                }];
                
                // Reload table data
                [strongSelf.tableView reloadData];
                [strongSelf installPageupKitOrNot:YES];
                [strongSelf installLoadMoreKitOrNot:YES];
                
                // Posttion to living
                [strongSelf positionToLivig];
                
            } else {
                // Reload table data
                [strongSelf.tableView reloadData];
                [strongSelf installPageupKitOrNot:NO];
                [strongSelf installLoadMoreKitOrNot:NO];
                [strongSelf.pageStatusKit showNoData];
            }
            
        } else {
            
            // Insert new items
            // Insert new items
            NSUInteger originSectionNum = strongSelf.dayDateAndProgramsDictionary.count;
            __block NSUInteger insertSectionNum = 0;
            [returnn.dayProgramSets.allKeys enumerateObjectsUsingBlock:^(NSDate *dateKey,
                                                                         NSUInteger idx,
                                                                         BOOL *stop) {
                MutableOrderedDictionary<NSString*,MBMatchProgram*> *dictsInSection = strongSelf.dayDateAndProgramsDictionary[dateKey];
                if (!dictsInSection) {
                    dictsInSection = [MutableOrderedDictionary<NSString*,MBMatchProgram*> dictionary];
                    strongSelf.dayDateAndProgramsDictionary[dateKey] = dictsInSection;
                    insertSectionNum ++;
                }
                
                NSArray<MBMatchProgram*> *dayPrograms = returnn.dayProgramSets[dateKey];
                [dayPrograms enumerateObjectsUsingBlock:^(MBMatchProgram *prog, NSUInteger idx2, BOOL *stop) {
                    dictsInSection[prog.program_id] = prog;
                    if (prog.is_living > 0) {
                        // Add into living
                        NSMutableArray *livingsInDay = strongSelf.dayAndLivingIdsDictionary[dateKey];
                        if (!livingsInDay) {
                            livingsInDay = [NSMutableArray array];
                            strongSelf.dayAndLivingIdsDictionary[dateKey] = livingsInDay;
                        }
                        [livingsInDay removeObject:prog.program_id];
                        [livingsInDay addObject:prog.program_id];
                    }
                }];
            }];
            
            if (insertSectionNum > 0) {
                NSIndexSet *insertSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(originSectionNum, insertSectionNum)];
                [strongSelf.tableView beginUpdates];
                [strongSelf.tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationFade];
                [strongSelf.tableView endUpdates];
                [strongSelf installLoadMoreKitOrNot:YES];
            }
        }
        
        strongSelf.refreshButn.hidden = NO;
        strongSelf.positionToLivingButn.hidden = NO;
        
        [strongSelf startUpdateNowTimeTimerIfNeed];
        [strongSelf registerBackgroundTaskForUpdateNowTimeTimer];
        [strongSelf startRefreshLivingProgramsTimerIfNeed];
        [strongSelf registerBackgroundTaskForRefreshLivingProgramsTimer];
    }];
}

- (BOOL)shouldRefreshAllLivingPrograms {
    return _refreshLivingProgramsTimer && _refreshLivingProgramsTimer.isValid;
}

- (void)refreshAllLivingProgramsIfNeed {
    if (![self shouldRefreshAllLivingPrograms]) return;
    
    __weak typeof(self)weakSelf = self;
    [self.dataController refreshAllLivingProgramList:^(NSArray<MBMatchProgram *> *results,
                                                       MBQueryMatchInfoStatus status,
                                                       NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (![strongSelf shouldRefreshAllLivingPrograms]) return;
        if (status != MBQueryMatchInfoSuccess) return;
        
        
        // Update old living rows to 'Finished' state
        MutableOrderedDictionary *dayAndProgramsDictionary = [strongSelf.dayDateAndProgramsDictionary copy];
        OrderedDictionary<NSDate*,NSMutableArray<NSString*>*> *oldDayAndLivingIds = [strongSelf.dayAndLivingIdsDictionary copy];
        
        [oldDayAndLivingIds.allKeys enumerateObjectsUsingBlock:^(NSDate *dayKey,
                                                                 NSUInteger idx,
                                                                 BOOL *stop) {
            OrderedDictionary *dayPrograms = dayAndProgramsDictionary[dayKey];
            if (dayPrograms) {
                NSMutableArray<NSString *> *dayLivingIds = oldDayAndLivingIds[dayKey];
                [dayLivingIds enumerateObjectsUsingBlock:^(NSString *prog_id, NSUInteger idx, BOOL *stop) {
                    MBMatchProgram *existProg = dayPrograms[prog_id];
                    if (existProg) {
                        // Update to 'Finished' state
                        existProg.is_living = 0;
                    }
                }];
            }
        }];
        
        // Clear living records
        [strongSelf.dayAndLivingIdsDictionary removeAllObjects];
        
    
        // Update new living rows
        [results enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {
            NSDate *progDate = [NSDate dateWithTimeIntervalSince1970:obj.program_date];
            NSDate *dayDate = [progDate sameDayWithHour:0 minute:0 second:0];
            MutableOrderedDictionary<NSString*,MBMatchProgram*> *dayPrograms = dayAndProgramsDictionary[dayDate];
            if (dayPrograms) {
                NSUInteger existIdx = [dayPrograms.allKeys indexOfObject:obj.program_id];
                if (existIdx != NSNotFound) {
                    MBMatchProgram *oldProg = dayPrograms[obj.program_id];
                    [oldProg fillPropertiesWithAnother:obj ignoreUnkownValueFields:YES];
                    
                    // Add into living
                    NSMutableArray *programs = strongSelf.dayAndLivingIdsDictionary[dayDate];
                    if (!programs) {
                        programs = [NSMutableArray array];
                        strongSelf.dayAndLivingIdsDictionary[dayDate] = programs;
                    }
                    [programs removeObject:obj.program_id];
                    [programs addObject:obj.program_id];
                }
            }
        }];
        
        // Reload sections for living and before living
        NSDate *lastLivingDay = strongSelf.dayAndLivingIdsDictionary.allKeys.lastObject;
        if (!lastLivingDay) lastLivingDay = oldDayAndLivingIds.allKeys.lastObject;
        if (lastLivingDay) {
            NSUInteger lastLivingDayIdx = [strongSelf.dayDateAndProgramsDictionary.allKeys indexOfObject:lastLivingDay];
            if (lastLivingDayIdx != NSNotFound) {
                [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, lastLivingDayIdx + 1)] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }];
}

- (void)applicationDidBecomeActive:(NSNotification *)note {
    if (_updateNowTimeTimerBackgroundTask == UIBackgroundTaskInvalid) {
        [self startUpdateNowTimeTimerIfNeed];
    }
    
    if (_refreshLivingProgramsTimerBackgroundTask == UIBackgroundTaskInvalid) {
        [self startRefreshLivingProgramsTimerIfNeed];
    }
}

- (void)registerBackgroundTaskForUpdateNowTimeTimer {
    __weak typeof(self)weakSelf = self;
    _updateNowTimeTimerBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf endBackgroundTaskForUpdateNowTimeTimer];
    }];
}

- (void)endBackgroundTaskForUpdateNowTimeTimer {
    if (_updateNowTimeTimerBackgroundTask == UIBackgroundTaskInvalid) return;
    
    [[UIApplication sharedApplication] endBackgroundTask:_updateNowTimeTimerBackgroundTask];
    _updateNowTimeTimerBackgroundTask = UIBackgroundTaskInvalid;
}

- (void)startUpdateNowTimeTimerIfNeed {
    if (_dayDateAndProgramsDictionary.count == 0) return;
    
    [_updateNowTimeTimer invalidate];
    _updateNowTimeTimer = nil;
    
    // 更新现在时间
    _nowTimestamp = [NSDate date].timeIntervalSince1970;
    
    __weak typeof(self)weakSelf = self;
    _updateNowTimeTimer = [NSTimer timerWithTimeInterval:1 block:^(NSTimer *timer) {
        weakSelf.nowTimestamp ++;
    } repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_updateNowTimeTimer forMode:NSRunLoopCommonModes];
}

- (void)stopUpdateNowTimeTimer {
    [_updateNowTimeTimer invalidate];
    _updateNowTimeTimer = nil;
}

- (void)registerBackgroundTaskForRefreshLivingProgramsTimer {
    __weak typeof(self)weakSelf = self;
    _refreshLivingProgramsTimerBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf endBackgroundTaskForRefreshLivingProgramsTimer];
    }];
}

- (void)endBackgroundTaskForRefreshLivingProgramsTimer {
    if (_refreshLivingProgramsTimerBackgroundTask == UIBackgroundTaskInvalid) return;
    
    [[UIApplication sharedApplication] endBackgroundTask:_refreshLivingProgramsTimerBackgroundTask];
    _refreshLivingProgramsTimerBackgroundTask = UIBackgroundTaskInvalid;
}

- (void)startRefreshLivingProgramsTimerIfNeed {
    if (_dayDateAndProgramsDictionary.count == 0) return;
    
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

- (void)navToSettings {
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (UIEdgeInsets)cellBodyInsetAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    return UIEdgeInsetsMake(row==0?0:12, 12, 0, 12);
}


/**
  添加或取消某个节目的提醒

 @param addOrCancel     添加或取消提醒
 @param indexPath       该节目所在行
 */
- (void)toggleReminder:(BOOL)addOrCancel
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    if (self.isDataLoading) return;
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    OrderedDictionary<NSDate*,MutableOrderedDictionary*> *programsDict = [self.dayDateAndProgramsDictionary copy];
    
    if (programsDict.count <= section) return;
    if (programsDict[section].count <= row) return;
    
    MBMatchProgram *prog = programsDict[section].allValues[row];
    if (addOrCancel) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        __weak typeof(self)weakSelf = self;
        [self.dataController addRemindForProgramWithId:prog.program_id handler:^(BOOL success) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (!weakSelf) return;
            if (weakSelf.isDataLoading) return;
            if (!success) return;
            prog.focused = YES;
            ProgramItemTableCell *tarCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            if (tarCell) {
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    } else {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        __weak typeof(self)weakSelf = self;
        [self.dataController removeRemindForProgramWithId:prog.program_id handler:^(BOOL success) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (!weakSelf) return;
            if (weakSelf.isDataLoading) return;
            if (!success) return;
            prog.focused = NO;
            ProgramItemTableCell *tarCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            if (tarCell) {
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

- (void)showDetailForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    OrderedDictionary<NSDate*,MutableOrderedDictionary*> *programsDict = [self.dayDateAndProgramsDictionary copy];
    
    if (programsDict.count <= section) return;
    if (programsDict[section].count <= row) return;
    
    MBMatchProgram *prog = programsDict[section].allValues[row];
    NSURL *detailUrl = prog.detail_link?[NSURL URLWithString:prog.detail_link]:nil;
    if (detailUrl) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:detailUrl entersReaderIfAvailable:YES];
        [self presentViewController:safariVC animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 根据上一次的列表类型决定当前列表类型
    MBDataControllerMatchListType listType = MBDataControllerMatchList_All;
    NSInteger lastOpenedListType = [MBPrefs shared].lastOpenedListType;
    if ([MBPrefs shared].rememberLastOpenedListType && lastOpenedListType != NSNotFound) {
        listType = lastOpenedListType;
    }
    // Update listType
    [self setListType:listType];
    
    self.navigationItem.titleView = [self categoryFilterButnTitleView];
    self.navigationItem.rightBarButtonItem = [self settingBarItem];
    
    self.view.backgroundColor = [MBColorSpecs app_pageBackground];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.view addSubview:self.positionToLivingButn];
    [self.view addSubview:self.refreshButn];
    
    // 根据设置设置定位置
    [self.refreshButn mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([MBPrefs shared].listOperateItemsPosition == MBProgramListOperateItemsPostionRight) {
            make.trailing.mas_equalTo(-16);
        } else {
            make.leading.mas_equalTo(16);
        }
        make.bottom.mas_equalTo(-30);
    }];
    __weak typeof(self)weakSelf = self;
    [self.positionToLivingButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.refreshButn.mas_centerX);
        make.bottom.equalTo(weakSelf.refreshButn.mas_top).offset(-16);
    }];
    
    self.refreshButn.hidden = YES;
    self.positionToLivingButn.hidden = YES;
    
    // 监听设置项的变化
    [self.prefsWormhole listenForMessageWithIdentifier:MBProgramLiveAutoRefreshIntervalStoreIdentifier listener:^(id  messageObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf startRefreshLivingProgramsTimerIfNeed];
        });
    }];
    
    [self.prefsWormhole listenForMessageWithIdentifier:MBProgramListOperateItemsPostionStoreIdentifier listener:^(id messageObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateListOperateItemsPosition];
        });
    }];
    
    [self.prefsWormhole listenForMessageWithIdentifier:MBListDayDateSectionHeaderFixedStoreIdentifier listener:^(id messageObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf resetTableView];
        });
    }];
    
    [self.prefsWormhole listenForMessageWithIdentifier:MBRememberLastOpenedListTypeStoreIdentifier listener:^(id messageObject) {
        if (!weakSelf) return;
        if ([MBPrefs shared].rememberLastOpenedListType) {
            [MBPrefs shared].lastOpenedListType = weakSelf.listType;
        }
    }];
}

- (void)dealloc {
    
    [_pageupKit uninstall];
    [_loadMoreKit uninstall];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self stopUpdateNowTimeTimer];
    [self endBackgroundTaskForUpdateNowTimeTimer];
    
    [self stopRefreshLivingProgramsTimer];
    [self endBackgroundTaskForRefreshLivingProgramsTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _viewDidLayoutSubviewsCallNum ++;
    if (_viewDidLayoutSubviewsCallNum == 1) {
        [self loadFirstPageProgramList];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dayDateAndProgramsDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dayDateAndProgramsDictionary.allValues[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    MBMatchProgram *prog = self.dayDateAndProgramsDictionary.allValues[section].allValues[row];
    ProgramItemCellModel *data = [ProgramItemCellModel modelWithProgram:prog currentTimestamp:self.nowTimestamp];
    if (data.cellType == ProgramItemCellType_HasStarted && !self.isDataFromRefresh) {
        // 不确定已经开始的节目的状态是否有效，所以不显示
        data.statusText = nil;
    }
    
    // 是否设置提醒
    data.hasSettedRemind = prog.focused;
    
    data.bodyInset = [self cellBodyInsetAtIndexPath:indexPath];
    
    ProgramItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProgramItemTableCell reuseIdentifierWithCellType:data.cellType] forIndexPath:indexPath];
    
    [cell configureWithData:data];
    
    __weak typeof(self)weakSelf = self;
    cell.toggleReminderBlock = ^(ProgramItemTableCell *cell) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        [weakSelf toggleReminder:!cell.data.hasSettedRemind
               forRowAtIndexPath:indexPath];
    };
    
    cell.detailBlock = ^(ProgramItemTableCell *cell) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        [weakSelf showDetailForRowAtIndexPath:indexPath];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ProgramItemTableCell cellHeightWithBodyInset:[self cellBodyInsetAtIndexPath:indexPath]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [self.dayDateAndProgramsDictionary.allKeys[section] dayOfMonthAndDayOfWeekFormattedResult];
    
    ProgramsSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:MainViewControllerListSectionHeader];
    header.backgroundView.backgroundColor = self.view.backgroundColor;
    header.contentView.backgroundColor = self.view.backgroundColor;
    [header setTitleText:sectionTitle];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [ProgramsSectionHeader defaultHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12.f;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    NSIndexPath *tarPositionIdx = [self findFisrtLivingProgramIndexPath];
    if (!tarPositionIdx) {
        tarPositionIdx = [self findMostRecentProgramIndexPath];
    }
    if (!tarPositionIdx) return;
    
    BOOL showScrollUpImg = YES;
    if (![visibleIndexPaths containsObject:tarPositionIdx]) {
        NSIndexPath *lastVisiableIdx = [visibleIndexPaths lastObject];
        if ((lastVisiableIdx.section < tarPositionIdx.section) || ((lastVisiableIdx.section == tarPositionIdx.section) && (lastVisiableIdx.row < tarPositionIdx.row))) {
            // tar idx is behind
            showScrollUpImg = NO;
        }
    }
    UIImage *butnImg = [UIImage imageNamed:showScrollUpImg?@"scroll_up_to_living_ic":@"scroll_down_to_living_ic"];
    [self.positionToLivingButn setImage:butnImg forState:UIControlStateNormal];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

@end
