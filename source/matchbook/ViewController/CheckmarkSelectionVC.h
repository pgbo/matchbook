//
//  CheckmarkSelectionVC.h
//  matchbook
//
//  Created by guangbool on 2017/7/17.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>


/**
 Checkmark 类型选择项目的 VC
 */
@interface CheckmarkSelectionVC : UITableViewController

/**
 是否显示描述图片
 */
@property (nonatomic, readonly) BOOL showDescriptionImage;

/**
  描述图片的尺寸
 */
@property (nonatomic, readonly) CGSize descriptionImageSize;

/**
  选项的图片描述 dataSource
 */
@property (nonatomic, copy) YYImage*(^descriptionImageForItem)(NSUInteger itemIdx);

/**
 选项列表
 */
@property (nonatomic, copy) NSArray<NSString *> *itemTitles;

/**
 选中项索引
 */
@property (nonatomic, assign) NSUInteger selectionIdx;

/**
 选项选中 block
 */
@property (nonatomic, copy) void(^itemDidSelectedBlock)(CheckmarkSelectionVC *vc, NSUInteger idx);

- (instancetype)initWithShowDescriptionImage:(BOOL)showDescriptionImage
                        descriptionImageSize:(CGSize)descriptionImageSize
                                  itemTitles:(NSArray<NSString *> *)itemTitles;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
