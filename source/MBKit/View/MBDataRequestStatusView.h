//
//  MBDataRequestStatusView.h
//  matchbook
//
//  Created by guangbool on 2017/6/27.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBDataRequestStatusViewLayout;

/**
 *  Follow is the structure of `MBLoadingView`
 
 *   ____________________
 *  |    MBLoadingView   |
 *  |  ________________  |
 *  | |                | |
 *  | |  imageView     | |
 *  | |                | |
 *  | |________________| |
 *  |  ________________  |
 *  | |                | |
 *  | |  textLabel     | |
 *  | |________________| |
 *  |                    |
 *  |____________________|
 */
@interface MBDataRequestStatusView : UIView

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *textLabel;

/**
 布局。修改该值会重新计算‘intrinsicContentSize’
 */
@property (nonatomic, copy) MBDataRequestStatusViewLayout *layout;

- (void)invalidateIntrinsicContentSize;
- (CGSize)intrinsicContentSize;

@end

@interface MBDataRequestStatusViewLayout : NSObject <NSCopying, NSCoding>

@property (nonatomic) CGFloat width;
@property (nonatomic) UIEdgeInsets imageViewInsets;
@property (nonatomic) CGFloat imageViewHeight;
@property (nonatomic) UIEdgeInsets textLabelInsets;

@end
