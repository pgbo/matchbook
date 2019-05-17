//
//  SettingsViewController.m
//  matchbook
//
//  Created by 彭光波 on 2017/7/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "SettingsViewController.h"
#import <MBKit/MBPrefs.h>
#import <MBKit/MBSpecs.h>
#import <MBKit/UITraitCollection+TDKit.h>
#import <MBKit/UIViewController+TDKit.h>
#import <MBKit/OrderedDictionary.h>
#import "PreferenceItemCell.h"
#import "CheckmarkSelectionVC.h"
#import "NSString+MBApp.h"
#import "AboutViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}

- (NSString *)rowTitleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *title = nil;
    if (section == 0) {
        if (row == 0) title = @"比分自动更新频率";
        if (row == 1) title = @"列表操作项位置";
        if (row == 2) title = @"固定节目列表的日期头";
        if (row == 3) title = @"节目提醒时间";
        if (row == 4) title = @"记住上次打开的列表类型";
    } else if (section == 1) {
        if (row == 0) title = @"Widget展开后节目数量";
        if (row == 1) title = @"Widget列表项点击查看详情";
        if (row == 2) title = @"是否启用触感反馈";
    } else if (section == 2) {
        if (row == 0) title = @"联系我们";
        if (row == 1) title = @"赞美比赛目录";
        if (row == 2) title = @"关于比赛目录";
    } else if (section == 3) {
        if (row == 0) title = @"还原应用设置";
    }
    
    return title;
}

- (PreferenceItemCell *)switchTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(switchTypeCellDequeued));
    PreferenceItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (PreferenceDisclosureIndicatorCell *)disclosureIndicatorTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(disclosureIndicatorTypeCellDequeued));
    PreferenceDisclosureIndicatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceDisclosureIndicatorCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (void)navtoLiveRefreshIntervalSettingPage {
    
    NSIndexPath *optIdxPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray<NSNumber*> *allValues = MBProgramLiveAutoRefreshInterval_allValues();
    
    MutableOrderedDictionary<NSNumber*,NSString*> *intervals = [MutableOrderedDictionary dictionary];
    [allValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
        MBProgramLiveAutoRefreshInterval interval = [val integerValue];
        NSString *desc = [NSString descriptionOfLiveAutoRefreshInterval:interval];
        if (desc) {
            intervals[val] = desc;
        }
    }];
    
    CheckmarkSelectionVC *vc = [[CheckmarkSelectionVC alloc] initWithShowDescriptionImage:NO descriptionImageSize:CGSizeZero itemTitles:intervals.allValues];
    vc.navigationItem.title = [self rowTitleForRowAtIndexPath:optIdxPath];
    vc.selectionIdx = [intervals.allKeys indexOfObject:@([MBPrefs shared].liveAutoRefreshInterval)];
    __weak typeof(self)weakSelf = self;
    vc.itemDidSelectedBlock = ^(CheckmarkSelectionVC *vc, NSUInteger idx) {
        if (!weakSelf) return;
        
        // Update prefs
        if (intervals.count > idx) {
            [MBPrefs shared].liveAutoRefreshInterval = intervals.allKeys[idx].integerValue;
        }
        
        // Update view
        [weakSelf.tableView reloadRowsAtIndexPaths:@[optIdxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navtoListOperateItemsPositionSettingPage {
    
    NSIndexPath *optIdxPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray<NSNumber*> *allValues = MBProgramListOperateItemsPostion_allValues();
    
    MutableOrderedDictionary<NSNumber*,NSString*> *itemPostions = [MutableOrderedDictionary dictionary];
    [allValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
        MBProgramListOperateItemsPostion position = [val integerValue];
        NSString *desc = [NSString descriptionOfListOperateItemsPostion:position];
        if (desc) {
            itemPostions[val] = desc;
        }
    }];
    
    CheckmarkSelectionVC *vc = [[CheckmarkSelectionVC alloc] initWithShowDescriptionImage:YES descriptionImageSize:CGSizeMake(960.f, 626.f) itemTitles:itemPostions.allValues];
    vc.navigationItem.title = [self rowTitleForRowAtIndexPath:optIdxPath];
    vc.descriptionImageForItem = ^YYImage *(NSUInteger idx) {
        if (itemPostions.count <= idx) return nil;
        MBProgramListOperateItemsPostion psType = itemPostions.allKeys[idx].integerValue;
        YYImage *img = nil;
        switch (psType) {
            case MBProgramListOperateItemsPostionRight:
                img = [YYImage imageNamed:@"items_position_right.gif"];
                break;
            case MBProgramListOperateItemsPostionLeft:
                img = [YYImage imageNamed:@"items_position_left.gif"];
                break;
        }
        return img;
    };
    vc.selectionIdx = [itemPostions.allKeys indexOfObject:@([MBPrefs shared].listOperateItemsPosition)];
    __weak typeof(self)weakSelf = self;
    vc.itemDidSelectedBlock = ^(CheckmarkSelectionVC *vc, NSUInteger idx) {
        if (!weakSelf) return;
        
        // Update prefs
        if (itemPostions.count > idx) {
            [MBPrefs shared].listOperateItemsPosition = itemPostions.allKeys[idx].integerValue;
        }
        
        // Update view
        [weakSelf.tableView reloadRowsAtIndexPaths:@[optIdxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navtoListSectionHeaderFixedSettingPage {
    
    NSIndexPath *optIdxPath = [NSIndexPath indexPathForRow:2 inSection:0];
    NSArray<NSNumber*> *allValues = @[@(YES), @(NO)];
    
    MutableOrderedDictionary<NSNumber*,NSString*> *itemPostions = [MutableOrderedDictionary dictionary];
    [allValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
        BOOL ifFixed = [val integerValue];
        NSString *desc = [NSString descriptionOfPreferenceBoolValue:ifFixed];
        if (desc) {
            itemPostions[val] = desc;
        }
    }];
    
    CheckmarkSelectionVC *vc = [[CheckmarkSelectionVC alloc] initWithShowDescriptionImage:YES descriptionImageSize:CGSizeMake(750.f, 421.f) itemTitles:itemPostions.allValues];
    vc.navigationItem.title = [self rowTitleForRowAtIndexPath:optIdxPath];
    vc.descriptionImageForItem = ^YYImage *(NSUInteger idx) {
        if (itemPostions.count <= idx) return nil;
        BOOL ifFixed = itemPostions.allKeys[idx].boolValue;
        YYImage *img = nil;
        if (ifFixed) {
            img = [YYImage imageNamed:@"section_header_fixed.gif"];
        } else {
            img = [YYImage imageNamed:@"section_header_unfixed.gif"];
        }
        return img;
    };
    vc.selectionIdx = [itemPostions.allKeys indexOfObject:@([MBPrefs shared].listDayDateSectionHeaderFixed)];
    __weak typeof(self)weakSelf = self;
    vc.itemDidSelectedBlock = ^(CheckmarkSelectionVC *vc, NSUInteger idx) {
        if (!weakSelf) return;
        
        // Update prefs
        if (itemPostions.count > idx) {
            [MBPrefs shared].listDayDateSectionHeaderFixed = itemPostions.allKeys[idx].boolValue;
        }
        
        // Update view
        [weakSelf.tableView reloadRowsAtIndexPaths:@[optIdxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navtoProgramRemindTimeSettingPage {
    
    NSIndexPath *optIdxPath = [NSIndexPath indexPathForRow:3 inSection:0];
    NSArray<NSNumber*> *allValues = MBProgramRemindTime_allValues();
    
    MutableOrderedDictionary<NSNumber*,NSString*> *remindTimes = [MutableOrderedDictionary dictionary];
    [allValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
        MBProgramRemindTime remindTime = [val integerValue];
        NSString *desc = [NSString descriptionOfProgramRemindTime:remindTime];
        if (desc) {
            remindTimes[val] = desc;
        }
    }];
    
    CheckmarkSelectionVC *vc = [[CheckmarkSelectionVC alloc] initWithShowDescriptionImage:NO descriptionImageSize:CGSizeZero itemTitles:remindTimes.allValues];
    vc.navigationItem.title = [self rowTitleForRowAtIndexPath:optIdxPath];
    vc.selectionIdx = [remindTimes.allKeys indexOfObject:@([MBPrefs shared].programRemindTime)];
    __weak typeof(self)weakSelf = self;
    vc.itemDidSelectedBlock = ^(CheckmarkSelectionVC *vc, NSUInteger idx) {
        if (!weakSelf) return;
        
        // Update prefs
        if (remindTimes.count > idx) {
            [MBPrefs shared].programRemindTime = remindTimes.allKeys[idx].integerValue;
        }
        
        // Update view
        [weakSelf.tableView reloadRowsAtIndexPaths:@[optIdxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navtoListDisplayNumInExpandedWidgetSettingPage {
    
    NSIndexPath *optIdxPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSArray<NSNumber*> *allValues = MBListDisplayNumInExpandedWidget_allValues();
    
    MutableOrderedDictionary<NSNumber*,NSString*> *displayNums = [MutableOrderedDictionary dictionary];
    [allValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
        MBListDisplayNumInExpandedWidget displayNum = [val integerValue];
        NSString *desc = [NSString descriptionOfListDisplayNumInExpandedWidget:displayNum];
        if (desc) {
            displayNums[val] = desc;
        }
    }];
    
    CheckmarkSelectionVC *vc = [[CheckmarkSelectionVC alloc] initWithShowDescriptionImage:NO descriptionImageSize:CGSizeZero itemTitles:displayNums.allValues];
    vc.navigationItem.title = [self rowTitleForRowAtIndexPath:optIdxPath];
    vc.selectionIdx = [displayNums.allKeys indexOfObject:@([MBPrefs shared].listDisplayNumInExpandedWidget)];
    __weak typeof(self)weakSelf = self;
    vc.itemDidSelectedBlock = ^(CheckmarkSelectionVC *vc, NSUInteger idx) {
        if (!weakSelf) return;
        
        // Update prefs
        if (displayNums.count > idx) {
            [MBPrefs shared].listDisplayNumInExpandedWidget = displayNums.allKeys[idx].integerValue;
        }
        
        // Update view
        [weakSelf.tableView reloadRowsAtIndexPaths:@[optIdxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)contactUS {
    // 评价页
    NSString *contactMail = @"devbool@126.com";
    NSURL *contactURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:devbool%@", contactMail]];
    [self openURL:contactURL];
}

- (void)commentMe {
    // 评价页
    NSURL *url1 = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&id=1257797109"];
    // app 首页
    NSURL *url2 = [NSURL URLWithString:@"https://itunes.apple.com/app/id1257797109"];
    if ([[UIApplication sharedApplication] canOpenURL:url1]) {
        [self openURL:url1];
    } else {
        [self openURL:url2];
    }
}

- (void)tryToResetPrefs {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"确认还原设置吗?" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    __weak typeof(self)weakSelf = self;
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"是的，还原" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[MBPrefs shared] resetLiveAutoRefreshInterval];
        [[MBPrefs shared] resetListOperateItemsPosition];
        [[MBPrefs shared] resetListDayDateSectionHeaderFixed];
        [[MBPrefs shared] resetProgramRemindTime];
        [[MBPrefs shared] resetRememberLastOpenedListType];
        
        [[MBPrefs shared] resetListDisplayNumInExpandedWidget];
        [[MBPrefs shared] resetClickWidgetProgramItemShowDetail];
        [[MBPrefs shared] resetUseTapticPeek];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf) return;
            // 只需刷新相应数据的表格行
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
        });
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    self.tableView.backgroundColor = [MBColorSpecs app_pageBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [MBColorSpecs app_separator];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = [MBHeight app_prefsCellHeight];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.clearsSelectionOnViewWillAppear = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rowNum = 0;
    if (section == 0) {
        rowNum = 5;
    } else if (section == 1) {
        rowNum = 3;
    } else if (section == 2) {
        rowNum = 3;
    } else if (section == 3) {
        rowNum = 1;
    }
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 4) {
            PreferenceItemCell *cell = [self switchTypeCellDequeued];
            cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
                [MBPrefs shared].rememberLastOpenedListType = on;
            };
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeSwitch;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model.subTitle = @"下次打开 App 时，将显示上次类型的列表";
                model;
            })];
            cell.switchOn = [MBPrefs shared].rememberLastOpenedListType;
            return cell;
        } else {
            PreferenceDisclosureIndicatorCell *cell = [self disclosureIndicatorTypeCellDequeued];
            cell.textLabel.text = [self rowTitleForRowAtIndexPath:indexPath];
            if (row == 0) {
                cell.detailTextLabel.text = [NSString descriptionOfLiveAutoRefreshInterval:[MBPrefs shared].liveAutoRefreshInterval];
            } else if (row == 1) {
                cell.detailTextLabel.text = [NSString descriptionOfListOperateItemsPostion:[MBPrefs shared].listOperateItemsPosition];
            } else if (row == 2) {
                cell.detailTextLabel.text = [NSString descriptionOfPreferenceBoolValue:[MBPrefs shared].listDayDateSectionHeaderFixed];
            } else if (row == 3) {
                cell.detailTextLabel.text = [NSString descriptionOfProgramRemindTime:[MBPrefs shared].programRemindTime];
            }
            return cell;
        }
    } else if (section == 1) {
        if (row == 0) {
            PreferenceDisclosureIndicatorCell *cell = [self disclosureIndicatorTypeCellDequeued];
            cell.textLabel.text = [self rowTitleForRowAtIndexPath:indexPath];
            cell.detailTextLabel.text = [NSString descriptionOfListDisplayNumInExpandedWidget:[MBPrefs shared].listDisplayNumInExpandedWidget];
            return cell;
        } else if (row == 1) {
            PreferenceItemCell *cell = [self switchTypeCellDequeued];
            cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
                [MBPrefs shared].clickWidgetProgramItemShowDetail = on;
            };
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeSwitch;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model.subTitle = @"如果节目存在详情，点击节目后将会在App中打开详情";
                model;
            })];
            cell.switchOn = [MBPrefs shared].clickWidgetProgramItemShowDetail;
            return cell;
        } else if (row == 2) {
            PreferenceItemCell *cell = [self switchTypeCellDequeued];
            cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
                [MBPrefs shared].useTapticPeek = on;
                if (on) {
                    [self.traitCollection tapticPeekVibrate];
                }
            };
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeSwitch;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model;
            })];
            cell.switchOn = [MBPrefs shared].useTapticPeek;
            return cell;
        }
    } else if (section == 2) {
        PreferenceDisclosureIndicatorCell *cell = [self disclosureIndicatorTypeCellDequeued];
        cell.textLabel.text = [self rowTitleForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = nil;
        return cell;
    } else if (section == 3) {
        PreferenceDisclosureIndicatorCell *cell = [self disclosureIndicatorTypeCellDequeued];
        cell.textLabel.text = [self rowTitleForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = nil;
        cell.showDisclosureIndicator = NO;
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [self navtoLiveRefreshIntervalSettingPage];
            return;
        } else if (row == 1) {
            [self navtoListOperateItemsPositionSettingPage];
            return;
        } else if (row == 2) {
            [self navtoListSectionHeaderFixedSettingPage];
            return;
        } else if (row == 3) {
            [self navtoProgramRemindTimeSettingPage];
            return;
        } else if (row == 4){
            // Switch type, do nothing
            return;
        }
    } else if (section == 1) {
        if (row == 0) {
            [self navtoListDisplayNumInExpandedWidgetSettingPage];
            return;
        } else if (row == 1) {
            // Switch type, do nothing
            return;
        }
    } else if (section == 2) {
        if (row == 0) {
            // 联系我们
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self contactUS];
            return;
        } else if (row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self commentMe];
            return;
        } else if (row == 2){
            // 关于
            [self.navigationController pushViewController:[[AboutViewController alloc] init] animated:YES];
            return;
        }
    } else if (section == 3) {
        if (row == 0) {
            // 还原设置
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self tryToResetPrefs];
            return;
        }
    }
}

@end
