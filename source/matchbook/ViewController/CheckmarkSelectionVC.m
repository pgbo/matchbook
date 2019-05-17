//
//  CheckmarkSelectionVC.m
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "CheckmarkSelectionVC.h"
#import <MBKit/MBSpecs.h>
#import "PreferenceItemCell.h"

@interface CheckmarkSelectionVC ()

@property (nonatomic) YYAnimatedImageView *descriptionImageView;

@end

@implementation CheckmarkSelectionVC

- (instancetype)initWithShowDescriptionImage:(BOOL)showDescriptionImage
                        descriptionImageSize:(CGSize)descriptionImageSize
                                  itemTitles:(NSArray<NSString *> *)itemTitles {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _showDescriptionImage = showDescriptionImage;
        _descriptionImageSize = descriptionImageSize;
        _itemTitles = [itemTitles copy];
    }
    return self;
}

- (YYAnimatedImageView *)descriptionImageView {
    if (!_descriptionImageView) {
        _descriptionImageView = [[YYAnimatedImageView alloc] init];
        _descriptionImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _descriptionImageView;
}

- (PreferenceItemCell *)checkmarkTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(checkmarkTypeCellDequeued));
    PreferenceItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (void)setDescriptionImageForItem:(YYImage *(^)(NSUInteger))descriptionImageForItem {
    _descriptionImageForItem = [descriptionImageForItem copy];
    
    [self displayDescriptionImage];
}

- (void)setItemTitles:(NSArray<NSString *> *)itemTitles {
    _itemTitles = [itemTitles copy];
    _selectionIdx = NSNotFound;
    [self.tableView reloadData];
}

- (void)setSelectionIdx:(NSUInteger)selectionIdx {
    _selectionIdx = selectionIdx;
    
    [self displayDescriptionImage];
    
    [self.tableView reloadData];
}

- (void)displayDescriptionImage {
    YYImage *img = self.descriptionImageForItem?self.descriptionImageForItem(self.selectionIdx):nil;
    _descriptionImageView.image = img;
    if (img && img.animatedImageType == YYImageTypeGIF) {
        [_descriptionImageView startAnimating];
    } else {
        [_descriptionImageView stopAnimating];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [MBColorSpecs app_pageBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [MBColorSpecs app_separator];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = [MBHeight app_prefsCellHeight];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    if (self.showDescriptionImage && self.descriptionImageSize.width > 0 && self.descriptionImageSize.height > 0) {
        self.tableView.tableFooterView = self.descriptionImageView;
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 16*2;
        CGFloat height = (self.descriptionImageSize.height/self.descriptionImageSize.width)*width;
        self.descriptionImageView.frame = CGRectMake(0, 0, width, height);
        self.descriptionImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    [self displayDescriptionImage];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PreferenceItemCell *cell = [self checkmarkTypeCellDequeued];
    [cell configureWithModel:({
        PreferenceItemCellModel *info = [PreferenceItemCellModel new];
        info.type = PreferenceTypeCheckmark;
        info.title = self.itemTitles[indexPath.row];
        info;
    })];
    cell.checked = (self.selectionIdx == indexPath.row);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger currentSelectionIdx = indexPath.row;
    NSUInteger originSelectionIdx = self.selectionIdx;
    if (originSelectionIdx != currentSelectionIdx) {
        if (originSelectionIdx != NSNotFound) {
            // Set origin checked cell to unchecked
            PreferenceItemCell *originCheckedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:originSelectionIdx inSection:0]];
            originCheckedCell.checked = NO;
        }
        
        // Set new checked cell
        PreferenceItemCell *optCell = [tableView cellForRowAtIndexPath:indexPath];
        optCell.checked = YES;
        
        // Update selection idx
        _selectionIdx = currentSelectionIdx;
    
        // Set description image
        [self displayDescriptionImage];
    }
    
    if (self.itemDidSelectedBlock) {
        self.itemDidSelectedBlock(self, currentSelectionIdx);
    }
}


@end
