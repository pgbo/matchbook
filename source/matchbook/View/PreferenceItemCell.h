//
//  PreferenceItemCell.h
//  tinyDict
//
//  Created by guangbool on 2017/4/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PreferenceItemCellType) {
    // checkmark type
    PreferenceTypeCheckmark = 0,
    // switch type
    PreferenceTypeSwitch,
    // movale type
    PreferenceTypeMovable
};

@class PreferenceItemCellModel;

@interface PreferenceItemCell : UITableViewCell

@property (nonatomic, readonly) PreferenceItemCellModel *model;

// This property only available when type is 'PreferenceTypeSwitch'
@property (nonatomic, assign) BOOL switchOn;

// This property only available when type is 'PreferenceTypeCheckmark'
@property (nonatomic, assign) BOOL checked;

@property (nonatomic, copy) void(^switchValueChangedBlock)(PreferenceItemCell *cell, BOOL on);

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureWithModel:(PreferenceItemCellModel *)model;

@end

@interface PreferenceItemCellModel : NSObject

@property (nonatomic, assign) PreferenceItemCellType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

@end

// Preference cell with disclosure indicator accessory
@interface PreferenceDisclosureIndicatorCell : UITableViewCell

// Whether show disclosure indicator. Default is YES
@property (nonatomic, assign) BOOL showDisclosureIndicator;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
