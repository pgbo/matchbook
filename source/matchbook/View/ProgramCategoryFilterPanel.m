//
//  ProgramCategoryFilterPanel.m
//  matchbook
//
//  Created by guangbool on 2017/6/26.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ProgramCategoryFilterPanel.h"
#import <MBKit/Masonry.h>
#import <MBKit/MBSpecs.h>

static NSString *const ProgramCategoryFilterPanelCell = @"ProgramCategoryFilterPanelCell";
static const NSUInteger ProgramCategoryFilterPanelCellTopSeparatorTag = 1881;
static const CGFloat ProgramCategoryFilterPanelCellHeight = 44.f;

@interface ProgramCategoryFilterPanel () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *table;

@end

@implementation ProgramCategoryFilterPanel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.rowHeight = ProgramCategoryFilterPanelCellHeight;
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}

- (UITableViewCell *)categoryCellDequeued {
    UITableViewCell *cell = [_table dequeueReusableCellWithIdentifier:ProgramCategoryFilterPanelCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProgramCategoryFilterPanelCell];
        cell.textLabel.font = [MBFontSpecs large];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *topSeparator = [UIView new];
        topSeparator.tag = ProgramCategoryFilterPanelCellTopSeparatorTag;
        topSeparator.backgroundColor = [MBColorSpecs app_separator];
        [cell.contentView addSubview:topSeparator];
        [topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo([MBPadding large]);
            make.trailing.mas_equalTo(-[MBPadding large]);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return cell;
}

- (void)setCategories:(NSArray<NSString *> *)categories {
    _categories = [categories copy];
    [_table reloadData];
    [self invalidateIntrinsicContentSize];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [_table reloadData];
}

- (void)setMaxIntrinsicContentHeight:(CGFloat)maxIntrinsicContentHeight {
    _maxIntrinsicContentHeight = maxIntrinsicContentHeight;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    CGFloat tableContentHeight = self.categories.count * ProgramCategoryFilterPanelCellHeight;
    CGRect frame = self.frame;
    CGFloat intrinsicHeight = MIN(tableContentHeight, self.maxIntrinsicContentHeight);
    return CGSizeMake(CGRectGetWidth(frame), intrinsicHeight);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [self categoryCellDequeued];
    
    // configure title
    cell.textLabel.text = self.categories[row];
    if (self.selectedIndex == row) {
        cell.textLabel.textColor = [MBColorSpecs app_themeTint];
    } else {
        cell.textLabel.textColor = [MBColorSpecs app_mainTextColor];
    }
    
    // hide or show separator
    [cell.contentView viewWithTag:ProgramCategoryFilterPanelCellTopSeparatorTag].hidden = (row == 0);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    self.selectedIndex = [indexPath row];
    [tableView reloadData];
    
    if (self.categoryDidSelected) {
        self.categoryDidSelected(self, self.selectedIndex);
    }
}

@end
