//
//  UIImage+MBApp.m
//  matchbook
//
//  Created by guangbool on 2017/6/26.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "UIImage+MBApp.h"
#import <MBKit/MBSpecs.h>
#import <MBKit/UIImage+TDKit.h>

@implementation UIImage (MBApp)

+ (UIImage *)mainPositiveBorderTransparentRoundedButtonBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"border_transparent_rounded_rect_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs app_mainPositiveTint]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)nornalPositiveBorderTransparentRoundedButtonBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"border_transparent_rounded_rect_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs app_normalPositiveTint]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)passiveBorderTransparentRoundedButtonBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"border_transparent_rounded_rect_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs app_passiveTint]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

@end
