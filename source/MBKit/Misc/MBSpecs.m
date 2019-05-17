//
//  MBSpecs.m
//  matchbook
//
//  Created by guangbool on 2017/6/22.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBSpecs.h"
#import "UIColor+TDKit.h"

/**
 UI specs
 */

@implementation MBColorSpecs

+ (UIColor *)wd_tint {
    return [self app_mainPositiveTint];
}

+ (UIColor *)wd_separator {
    static UIColor *wd_separator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wd_separator = [UIColor colorWithRGB:0xAAAAAA];
    });
    return wd_separator;
}

+ (UIColor *)wd_mainTextColor {
    return [self app_mainTextColor];
}

+ (UIColor *)wd_minorTextColor {
    return [self app_minorTextColor];
}

+ (UIColor *)app_themeTint {
    static UIColor *app_themeTint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_themeTint = [UIColor colorWithRGB:0x0AC775];
    });
    return app_themeTint;
}

+ (UIColor *)app_navigationText {
    static UIColor *app_navigationText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_navigationText = [UIColor colorWithRGB:0xFFFFFF];
    });
    return app_navigationText;
}

+ (UIColor *)app_mainPositiveTint {
    static UIColor *app_mainPositiveTint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_mainPositiveTint = [UIColor colorWithRGB:0x4B89AC];
    });
    return app_mainPositiveTint;
}

+ (UIColor *)app_normalPositiveTint {
    static UIColor *app_normalPositiveTint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_normalPositiveTint = [UIColor colorWithRGB:0xD8E9F0];
    });
    return app_normalPositiveTint;
}

+ (UIColor *)app_passiveTint {
    return [self app_minorTextColor];
}

+ (UIColor *)app_pageBackground {
    static UIColor *app_pageBackground = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_pageBackground = [UIColor colorWithRGB:0xEEEEEE];
    });
    return app_pageBackground;
}

+ (UIColor *)app_separator {
    static UIColor *app_separator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_separator = [UIColor colorWithRGB:0xEEEEEE];
    });
    return app_separator;
}

+ (UIColor *)app_mainTextColor {
    static UIColor *app_mainTextColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_mainTextColor = [UIColor colorWithRGB:0x555555];
    });
    return app_mainTextColor;
}

+ (UIColor *)app_minorTextColor {
    static UIColor *app_minorTextColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_minorTextColor = [UIColor colorWithRGB:0x808080];
    });
    return app_minorTextColor;
}

+ (UIColor *)app_cellColor {
    static UIColor *app_cellColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_cellColor = [UIColor colorWithRGB:0xffffff];
    });
    return app_cellColor;
}

+ (UIColor *)app_programListDayDateLabelBackgroud {
    static UIColor *app_programListDayDateLabelBackgroud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_programListDayDateLabelBackgroud = [UIColor colorWithRGB:0xe5e5e5];
    });
    return app_programListDayDateLabelBackgroud;
}

+ (UIColor *)liveMarkColor {
    static UIColor *liveMarkColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        liveMarkColor = [UIColor colorWithRGB:0xF24965];
    });
    return liveMarkColor;
}

+ (UIColor *)focusedMarkColor {
    static UIColor *focusedMarkColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        focusedMarkColor = [UIColor colorWithRGB:0xFFAB40];
    });
    return focusedMarkColor;
}

@end

@implementation MBFontSizeSpecs

+ (CGFloat)tiny {
    return 10;
}

+ (CGFloat)small {
    return 12;
}

+ (CGFloat)regular {
    return 14;
}

+ (CGFloat)large {
    return 16;
}

@end

@implementation MBFontSpecs

static NSString *const MBFontSpecsRegularName = @"Lato-Regular";
static NSString *const MBFontSpecsBoldName = @"Lato-Bold";

+ (UIFont *)tiny {
    static UIFont *tinyFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tinyFont = [UIFont fontWithName:MBFontSpecsRegularName size:[MBFontSizeSpecs tiny]];
    });
    return tinyFont;
}

+ (UIFont *)small {
    static UIFont *smallFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smallFont = [UIFont fontWithName:MBFontSpecsRegularName size:[MBFontSizeSpecs small]];
    });
    return smallFont;
}

+ (UIFont *)regular {
    static UIFont *regularFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularFont = [UIFont fontWithName:MBFontSpecsRegularName size:[MBFontSizeSpecs regular]];
    });
    return regularFont;
}

+ (UIFont *)large {
    static UIFont *largeFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        largeFont = [UIFont fontWithName:MBFontSpecsRegularName size:[MBFontSizeSpecs large]];
    });
    return largeFont;
}

+ (UIFont *)tinyBold {
    static UIFont *tinyBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tinyBoldFont = [UIFont fontWithName:MBFontSpecsBoldName size:[MBFontSizeSpecs tiny]];
    });
    return tinyBoldFont;
}

+ (UIFont *)smallBold {
    static UIFont *smallBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smallBoldFont = [UIFont fontWithName:MBFontSpecsBoldName size:[MBFontSizeSpecs small]];
    });
    return smallBoldFont;
}

+ (UIFont *)regularBold {
    static UIFont *regularBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularBoldFont = [UIFont fontWithName:MBFontSpecsBoldName size:[MBFontSizeSpecs regular]];
    });
    return regularBoldFont;
}

+ (UIFont *)largeBold {
    static UIFont *largeBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        largeBoldFont = [UIFont fontWithName:MBFontSpecsBoldName size:[MBFontSizeSpecs large]];
    });
    return largeBoldFont;
}

@end

@implementation MBPadding

+ (CGFloat)tiny {
    return 4.f;
}

+ (CGFloat)small {
    return 8.f;
}

+ (CGFloat)regular {
    return 12.f;
}

+ (CGFloat)large {
    return 16.f;
}

+ (CGFloat)extra {
    return 20.f;
}

@end

@implementation MBHeight

+ (CGFloat)app_prefsCellHeight {
    return 44.f;
}

+ (CGFloat)app_bottomBarHeight {
    return 44.f;
}

+ (CGFloat)wd_programCellHeight {
    return 70.f;
}

@end
