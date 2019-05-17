//
//  MBSpecs.h
//  matchbook
//
//  Created by guangbool on 2017/6/22.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UI specs
 */

@interface MBColorSpecs : NSObject

+ (UIColor *)wd_tint;
+ (UIColor *)wd_separator;
+ (UIColor *)wd_mainTextColor;
+ (UIColor *)wd_minorTextColor;

+ (UIColor *)app_themeTint;
+ (UIColor *)app_navigationText;
+ (UIColor *)app_mainPositiveTint;
+ (UIColor *)app_normalPositiveTint;
+ (UIColor *)app_passiveTint;
+ (UIColor *)app_pageBackground;
+ (UIColor *)app_separator;
+ (UIColor *)app_mainTextColor;
+ (UIColor *)app_minorTextColor;
+ (UIColor *)app_cellColor;
+ (UIColor *)app_programListDayDateLabelBackgroud;
+ (UIColor *)liveMarkColor;
+ (UIColor *)focusedMarkColor;

@end

@interface MBFontSizeSpecs : NSObject

+ (CGFloat)tiny;
+ (CGFloat)small;
+ (CGFloat)regular;
+ (CGFloat)large;

@end

@interface MBFontSpecs : NSObject

+ (UIFont *)tiny;
+ (UIFont *)small;
+ (UIFont *)regular;
+ (UIFont *)large;
+ (UIFont *)tinyBold;
+ (UIFont *)smallBold;
+ (UIFont *)regularBold;
+ (UIFont *)largeBold;

@end

@interface MBPadding : NSObject

+ (CGFloat)tiny;
+ (CGFloat)small;
+ (CGFloat)regular;
+ (CGFloat)large;
+ (CGFloat)extra;

@end

@interface MBHeight : NSObject

+ (CGFloat)app_prefsCellHeight;
+ (CGFloat)app_bottomBarHeight;

+ (CGFloat)wd_programCellHeight;

@end
