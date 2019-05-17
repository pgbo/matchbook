//
//  UIView+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/4/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UIView+TDKit.h"

@implementation UIView (TDKit)

- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
