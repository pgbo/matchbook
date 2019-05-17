//
//  ExpandModeVC.m
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ExpandModeVC.h"
#import <MBKit/Masonry.h>
#import <MBKit/MBSpecs.h>
#import <MBKit/MBPrefs.h>
#import <MBKit/NSDate+TDKit.h>
#import "TodayProgramItemCell.h"
#import "UIImage+MBWidget.h"

@interface ExpandModeVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) MutableOrderedDictionary<NSString*/*program_id*/,MBMatchProgram*> *programsDictionary;
@property (nonatomic) NSArray<NSString*> *liveProgramIds;
@property (nonatomic) NSArray<NSString*> *focusedProgramIds;

@property (nonatomic, weak) IBOutlet UIView *dataContentView;
@property (nonatomic, weak) IBOutlet UITableView *listTable;
@property (nonatomic, weak) IBOutlet UIView *seperator;
@property (nonatomic, weak) IBOutlet UIView *filterGroupContainer;
@property (nonatomic, weak) IBOutlet UIView *pagerGroupContainer;
@property (nonatomic, weak) IBOutlet UIButton *liveRadioButn;
@property (nonatomic, weak) IBOutlet UIButton *focusedRadioButn;
@property (nonatomic, weak) IBOutlet UIButton *pageUpButn;
@property (nonatomic, weak) IBOutlet UIButton *pageDownButn;
@property (nonatomic, weak) IBOutlet UIButton *moreButn;

// Filter state
@property (nonatomic) BOOL includeLive;
@property (nonatomic) BOOL includeFocused;

// Pager
@property (nonatomic) NSUInteger currentPageFirstItemIdx;

// Cache for image
@property (nonatomic) UIImage *liveRadioOffIcon;
@property (nonatomic) UIImage *liveRadioOnIcon;
@property (nonatomic) UIImage *focusedRadioOffIcon;
@property (nonatomic) UIImage *focusedRadioOnIcon;

@property (nonatomic) NSUInteger viewDidLayoutSubviewsCallNum;

@end

@implementation ExpandModeVC

- (instancetype)initWithAllPrograms:(NSArray<MBMatchProgram*>*)programs {
    if (self = [super initWithNibName:NSStringFromClass([ExpandModeVC class]) bundle:nil]) {
        
        MutableOrderedDictionary *programDict = [MutableOrderedDictionary dictionary];
        NSMutableArray *liveIds = [NSMutableArray array];
        NSMutableArray *focusedIds = [NSMutableArray array];
        [programs enumerateObjectsUsingBlock:^(MBMatchProgram *prog,
                                               NSUInteger idx,
                                               BOOL *stop) {
            NSString *_id = prog.program_id;
            if (_id.length > 0
                && (prog.is_living > 0 || prog.focused)) {
                programDict[prog.program_id] = prog;
                if (prog.is_living > 0) [liveIds addObject:_id];
                if (prog.focused) [focusedIds addObject:_id];
            }
        }];
        self.programsDictionary = programDict;
        self.liveProgramIds = liveIds;
        self.focusedProgramIds = focusedIds;
        
        self.includeLive = YES;
        self.includeFocused = YES;
        self.currentPageFirstItemIdx = 0;
    }
    return self;
}

- (MutableOrderedDictionary<NSString *,MBMatchProgram *> *)programsDictionary {
    if (!_programsDictionary) {
        _programsDictionary = [MutableOrderedDictionary dictionary];
    }
    return _programsDictionary;
}

- (void)refreshLivePrograms:(NSArray<MBMatchProgram*> *)livePrgrams {
    NSMutableArray<NSString*> *newLiveIds = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    [livePrgrams enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {\
        NSString *_id = obj.program_id;
        if (obj.is_living > 0 && _id.length > 0) {
            [newLiveIds addObject:_id];
            MBMatchProgram *oldProg = weakSelf.programsDictionary[_id];
            if (oldProg) {
                [oldProg fillPropertiesWithAnother:obj ignoreUnkownValueFields:YES];
            }
        }
    }];
    self.liveProgramIds = newLiveIds;
    [self.listTable reloadData];
}

- (UIImage *)liveRadioOffIcon {
    if (!_liveRadioOffIcon) {
        _liveRadioOffIcon = [UIImage radioOffIconImageWithColor:[MBColorSpecs liveMarkColor]];
    }
    return _liveRadioOffIcon;
}

- (UIImage *)liveRadioOnIcon {
    if (!_liveRadioOnIcon) {
        _liveRadioOnIcon = [UIImage radioOnIconImageWithColor:[MBColorSpecs liveMarkColor]];
    }
    return _liveRadioOnIcon;
}

- (UIImage *)focusedRadioOffIcon {
    if (!_focusedRadioOffIcon) {
        _focusedRadioOffIcon = [UIImage radioOffIconImageWithColor:[MBColorSpecs focusedMarkColor]];
    }
    return _focusedRadioOffIcon;
}

- (UIImage *)focusedRadioOnIcon {
    if (!_focusedRadioOnIcon) {
        _focusedRadioOnIcon = [UIImage radioOnIconImageWithColor:[MBColorSpecs focusedMarkColor]];
    }
    return _focusedRadioOnIcon;
}

- (MBMatchProgram *)programForRowAtIndex:(NSUInteger)rowIdx {
    if (self.includeLive && self.includeFocused) {
        if (rowIdx < self.programsDictionary.count) {
            return self.programsDictionary.allValues[rowIdx];
        }
        return nil;
    }
    
    if (self.includeLive) {
        if (rowIdx < self.liveProgramIds.count) {
            NSString *_id = self.liveProgramIds[rowIdx];
            return self.programsDictionary[_id];
        }
        return nil;
    }
    
    if (self.includeFocused) {
        if (rowIdx < self.focusedProgramIds.count) {
            NSString *_id = self.focusedProgramIds[rowIdx];
            return self.programsDictionary[_id];
        }
        return nil;
    }
    
    return nil;
}


/**
 设置过滤

 @param includeLive    是否包括直播中
 @param includeFocused 是否包括关注
 @return 是否可以设置
 */
- (BOOL)setFilterIncludeLive:(BOOL)includeLive includeFocused:(BOOL)includeFocused {
    if (!includeLive && !includeFocused) return NO;
    if (self.includeLive == includeLive && self.includeFocused == includeFocused) return NO;
    
    self.includeLive = includeLive;
    self.includeFocused = includeFocused;
    // Reset 'currentPageFirstItemIdx'
    self.currentPageFirstItemIdx = 0;
    [self.listTable setContentOffset:CGPointZero];
    [self.listTable reloadData];
    return YES;
}

- (NSUInteger)listItemNumbersOnCurrentState {
    if (self.includeLive && self.includeFocused) return self.programsDictionary.count;
    if (self.includeLive) return self.liveProgramIds.count;
    if (self.includeFocused) return self.focusedProgramIds.count;
    return 0;
}

- (void)toggleLiveRadio:(id)sender {
    if ([self setFilterIncludeLive:!self.includeLive includeFocused:self.includeFocused]) {
        [self.liveRadioButn setImage:self.includeLive?self.liveRadioOnIcon:self.liveRadioOffIcon forState:UIControlStateNormal];
    }
    
    [self.traitCollection tapticPeekIfPossible];
}

- (void)toggleFocusedRadio:(id)sender {
    if ([self setFilterIncludeLive:self.includeLive includeFocused:!self.includeFocused]) {
        [self.focusedRadioButn setImage:self.includeFocused?self.focusedRadioOnIcon:self.focusedRadioOffIcon forState:UIControlStateNormal];
    }
    
    [self.traitCollection tapticPeekIfPossible];
}

+ (NSUInteger)pageItemDisplayNum {
    return [MBPrefs shared].listDisplayNumInExpandedWidget;
}

- (void)pageUp:(id)sender {
    
    [self.traitCollection tapticPeekIfPossible];
    
    NSUInteger currentPageFirstIdx = self.currentPageFirstItemIdx;
    NSInteger prePageOffset = currentPageFirstIdx - [self.class pageItemDisplayNum];
    if (prePageOffset < 0) prePageOffset = 0;
    if (prePageOffset == currentPageFirstIdx) {
        // TODO: 不能向上翻页了，增加一些动效提示
        return;
    }
    
    self.currentPageFirstItemIdx = prePageOffset;

    [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:prePageOffset
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)moreClick:(id)sender {
    [self.traitCollection tapticPeekIfPossible];
    if (self.moreBlock) self.moreBlock(self);
}

- (void)pageDown:(id)sender {
    
    [self.traitCollection tapticPeekIfPossible];
    
    NSUInteger pageItemDisplayNum = [self.class pageItemDisplayNum];
    NSUInteger currentFirstItemIdx = self.currentPageFirstItemIdx;
    NSUInteger listItemNum = [self listItemNumbersOnCurrentState];
    NSInteger nextPageOffset = currentFirstItemIdx + pageItemDisplayNum;
    if (nextPageOffset + pageItemDisplayNum  >= listItemNum) {
        nextPageOffset = listItemNum - pageItemDisplayNum;
    }
    if (nextPageOffset < 0) nextPageOffset = 0;
    if (nextPageOffset <= currentFirstItemIdx) {
        // TODO: 不能向下翻页了，增加一些动效提示
        return;
    }
    
    self.currentPageFirstItemIdx = nextPageOffset;

    [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentPageFirstItemIdx
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (NSUInteger)findMostRecentProgramIndex {
    
    NSArray *filteredIds = nil;
    if (self.includeLive && self.includeFocused) {
        filteredIds = self.programsDictionary.allKeys;
    } else if (self.includeLive) {
        filteredIds = [self.liveProgramIds copy];
    } else if (self.includeFocused) {
        filteredIds = [self.focusedProgramIds copy];
    }
    
    if (filteredIds.count == 0) return NSNotFound;
    
    OrderedDictionary<NSString *,MBMatchProgram *> *programs = [self.programsDictionary copy];
    
    NSDate *nowDate = [NSDate date];
    NSUInteger nowTimestamp = [nowDate timeIntervalSince1970];
    
    __block NSInteger minInterval = -1;
    __block NSUInteger tarIdx = NSNotFound;
    [filteredIds enumerateObjectsUsingBlock:^(NSString *_id, NSUInteger idx, BOOL *stop) {
        MBMatchProgram *prog = programs[_id];
        if (prog) {
            NSUInteger interval = (NSUInteger)abs((int)(prog.program_date - nowTimestamp));
            if (minInterval > interval) {
                minInterval = interval;
                tarIdx = idx;
            }
        }
    }];
    
    return tarIdx;
}

- (MBMatchProgram *)findMostRecentProgram {
    NSArray *filteredIds = nil;
    if (self.includeLive && self.includeFocused) {
        filteredIds = self.programsDictionary.allKeys;
    } else if (self.includeLive) {
        filteredIds = [self.liveProgramIds copy];
    } else if (self.includeFocused) {
        filteredIds = [self.focusedProgramIds copy];
    }
    
    if (filteredIds.count == 0) return nil;
    
    OrderedDictionary<NSString *,MBMatchProgram *> *programs = [self.programsDictionary copy];
    
    NSDate *nowDate = [NSDate date];
    NSUInteger nowTimestamp = [nowDate timeIntervalSince1970];
    
    NSInteger minInterval = -1;
    MBMatchProgram *tarProg = nil;
    for (NSString *_id in filteredIds) {
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

- (BOOL)isSmallScreenDevice {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minSideLength = fminf(screenSize.width, screenSize.height);
    return (minSideLength < 375.f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self.listTable registerNib:[TodayProgramItemCell nib] forCellReuseIdentifier:NSStringFromClass([TodayProgramItemCell class])];
    self.listTable.dataSource = self;
    self.listTable.delegate = self;
    
    self.filterGroupContainer.layer.borderColor = [MBColorSpecs wd_separator].CGColor;
    self.filterGroupContainer.layer.cornerRadius = 13.5;
    self.filterGroupContainer.layer.borderWidth = 0.5;
    
    self.pagerGroupContainer.layer.borderColor = [MBColorSpecs wd_separator].CGColor;
    self.pagerGroupContainer.layer.cornerRadius = 13.5;
    self.pagerGroupContainer.layer.borderWidth = 0.5;
    
    [self.liveRadioButn addTarget:self
                           action:@selector(toggleLiveRadio:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.focusedRadioButn addTarget:self
                              action:@selector(toggleFocusedRadio:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.pageUpButn addTarget:self
                        action:@selector(pageUp:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.pageDownButn addTarget:self
                          action:@selector(pageDown:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreButn addTarget:self
                      action:@selector(moreClick:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.liveRadioButn setImage:self.includeLive?self.liveRadioOnIcon:self.liveRadioOffIcon forState:UIControlStateNormal];
    
    [self.focusedRadioButn setImage:self.includeFocused?self.focusedRadioOnIcon:self.focusedRadioOffIcon forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    _viewDidLayoutSubviewsCallNum ++;
    if (_viewDidLayoutSubviewsCallNum == 1) {
        // Scroll to suitable indexPath
        NSUInteger listItemNum = [self listItemNumbersOnCurrentState];
        NSUInteger mostRecentProgramIdx = [self findMostRecentProgramIndex];
        if (mostRecentProgramIdx != NSNotFound) {
            self.currentPageFirstItemIdx = MIN(listItemNum - [self.class pageItemDisplayNum], mostRecentProgramIdx);
            [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentPageFirstItemIdx inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self listItemNumbersOnCurrentState];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayProgramItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TodayProgramItemCell class]) forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    MBMatchProgram *program = [self programForRowAtIndex:row];
    TodayProgramItemDataModel *data = [TodayProgramItemDataModel dataWithProgram:program];
    data.isFocused = [program focused];
    
    NSString *startTime = nil;
    NSDate *progDate = [NSDate dateWithTimeIntervalSince1970:program.program_date];
    MBMatchProgram *upperItem = row>0?[self programForRowAtIndex:row-1]:nil;
    if (upperItem) {
        NSDate *progDate = [NSDate dateWithTimeIntervalSince1970:program.program_date];
        NSDate *upperProgDate = [NSDate dateWithTimeIntervalSince1970:upperItem.program_date];
        if ([progDate sameDayTo:upperProgDate]) {
            startTime = [program program_daytime];
        }
    }
    if (!startTime) {
        NSString *dayStr = [progDate dayOfMonthFormattedResult];
        startTime = [NSString stringWithFormat:@"%@ %@", dayStr, [program program_daytime]?:@""];
    }
    data.startTime = startTime;
    
    [cell configureWithData:data];
    
    cell.showTopSeparator = (row != 0);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MBHeight wd_programCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBMatchProgram *prog = [self programForRowAtIndex:[indexPath row]];
    if (prog && self.programDidSelectedBlock) {
        self.programDidSelectedBlock(self, prog);
    }
}

@end
