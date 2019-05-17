//
//  UIImage+MBBundle.m
//  matchbook
//
//  Created by guangbool on 2017/6/26.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "UIImage+MBBundle.h"
#import <MBKit/MBSpecs.h>
#import <MBKit/UIImage+TDKit.h>

@implementation UIImage (MBBundle)

+ (UIImage *)homeTeamScoreViewBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"score_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs app_themeTint]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)visitTeamScoreViewBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"score_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs app_mainPositiveTint]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)liveMarkViewBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"status_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs liveMarkColor]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

+ (UIImage *)focusedMarkViewBackgroudImage {
    UIImage *sourceImg = [UIImage imageNamed:@"status_bg"];
    UIImage *tarImg = [sourceImg imageByTintColor:[MBColorSpecs focusedMarkColor]];
    tarImg = [tarImg resizableImageWithCapInsets:sourceImg.capInsets
                                    resizingMode:sourceImg.resizingMode];
    return tarImg;
}

@end
