//
//  UIImage+MBWidget.m
//  matchbook
//
//  Created by 彭光波 on 2017/7/22.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "UIImage+MBWidget.h"
#import <MBKit/UIImage+TDKit.h>

@implementation UIImage (MBWidget)

+ (UIImage *)toolGroupBorderImageWithColor:(UIColor *)color {
    UIImage *sourceImg = [UIImage imageNamed:@"widget_tool_group_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:color];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)radioOffIconImageWithColor:(UIColor *)color {
    UIImage *sourceImg = [UIImage imageNamed:@"widget_radio_off_ic"];
    UIImage *tarImg = [sourceImg imageByTintColor:color];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)radioOnIconImageWithColor:(UIColor *)color {
    UIImage *sourceImg = [UIImage imageNamed:@"widget_radio_on_ic"];
    UIImage *tarImg = [sourceImg imageByTintColor:color];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

@end
