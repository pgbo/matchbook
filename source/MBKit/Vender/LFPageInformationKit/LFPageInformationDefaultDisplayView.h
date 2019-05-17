//
//  LFPageInformationDefaultDisplayView.h
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LFPageInformationDisplayItem.h"

/**
 *  Follow is the structure of `LFPageInformationDefaultDisplayView`

 *   ____________________  
 *  |    DisplayView     |
 *  |  ________________  |
 *  | |                | |
 *  | |  imageView     | |
 *  | |                | |
 *  | |________________| |
 *  |  ________________  |
 *  | |                | |
 *  | |  textLabel     | |
 *  | |________________| |
 *  |  ________________  |
 *  | |                | |
 *  | |  actionButton  | |
 *  | |________________| |
 *  |____________________|
 */
@class LFPageInformationDefaultDisplayViewLayout;
@interface LFPageInformationDefaultDisplayView : UIView <LFPageInformationDisplayView>

// Default is `YES`
@property (nonatomic, assign) BOOL lfpi_hideBeforeAddIntoContainerView;
// Default is `YES`
@property (nonatomic, assign) BOOL lfpi_aliginCenter;
// Default is `YES`
@property (nonatomic, assign) BOOL lfpi_removeFromSuperViewWhenHide;

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UIButton *actionButton;
@property (nonatomic, readonly) LFPageInformationDefaultDisplayViewLayout *layout;

- (instancetype)initWithFrame:(CGRect)frame layout:(LFPageInformationDefaultDisplayViewLayout *)layout;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

@interface LFPageInformationDefaultDisplayViewLayout : NSObject <NSCopying, NSCoding>

@property (nonatomic) UIEdgeInsets imageViewInsets;
@property (nonatomic) CGFloat imageViewHeight;
@property (nonatomic) UIEdgeInsets textLabelInsets;
//@property (nonatomic) CGFloat textLabelHeight;
@property (nonatomic) UIEdgeInsets actionButtonInsets;
@property (nonatomic) CGFloat actionButtonHeight;

@end
