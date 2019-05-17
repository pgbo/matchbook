//
//  MBPageStatusKit+MBKit.m
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBPageStatusKit+MBKit.h"
#import "MBSpecs.h"

@implementation MBPageStatusKit (MBKit)

/**
 App 端默认全页状态套件
 
 @param containerView 容器视图
 @return 实例
 */
+ (MBPageStatusKit *)appDefaultWithContainer:(UIView *)containerView {
    
    MBPageStatusKit *obj = [[MBPageStatusKit alloc] initWithContainerView:containerView];
    
    NSBundle *bundle = [self bundle];
    
    // set `loadingImages`
    NSMutableArray<UIImage *> *loadingImgs = [NSMutableArray<UIImage *> array];
    for (NSInteger i = 0; i <= 8; i++) {
        NSString *key = [NSString stringWithFormat:@"basket_ball%@", @(i)];
        UIImage *img = [UIImage imageNamed:key inBundle:bundle compatibleWithTraitCollection:nil];
        if (img) [loadingImgs addObject:img];
    }
    obj.loadingImages = loadingImgs;
    
    // set `noDataImage`
    obj.noDataImage = [UIImage imageNamed:@"lol_ball" inBundle:bundle compatibleWithTraitCollection:nil];
    
    // set `noNetworkImage`
    obj.noNetworkImage = [UIImage imageNamed:@"lol_ball" inBundle:bundle compatibleWithTraitCollection:nil];
    
    // set `normalErrorImage`
    obj.normalErrorImage = [UIImage imageNamed:@"lol_ball" inBundle:bundle compatibleWithTraitCollection:nil];
    
    return obj;
}

/**
 App 端默认全页状态套件
 
 @param containerView 容器视图
 @return 实例
 */
+ (MBPageStatusKit *)widgetDefaultWithContainer:(UIView *)containerView {

    MBPageStatusKit *obj = [[MBPageStatusKit alloc] initWithContainerView:containerView];
    
    NSBundle *bundle = [self bundle];
    
    // set `loadingImages`
    NSMutableArray<UIImage *> *loadingImgs = [NSMutableArray<UIImage *> array];
    for (NSInteger i = 0; i <= 8; i++) {
        NSString *key = [NSString stringWithFormat:@"basket_ball%@", @(i)];
        UIImage *img = [UIImage imageNamed:key inBundle:bundle compatibleWithTraitCollection:nil];
        if (img) [loadingImgs addObject:img];
    }
    obj.loadingImages = loadingImgs;
    
    // set `noDataImage`
    obj.noDataImage = [UIImage imageNamed:@"lol_ball_small" inBundle:bundle compatibleWithTraitCollection:nil];
    
    // set `noNetworkImage`
    obj.noNetworkImage = [UIImage imageNamed:@"lol_ball_small" inBundle:bundle compatibleWithTraitCollection:nil];
    
    // set `normalErrorImage`
    obj.normalErrorImage = [UIImage imageNamed:@"lol_ball_small" inBundle:bundle compatibleWithTraitCollection:nil];
    
    UIFont *defaultFont = [MBFontSpecs small];
    UIColor *defaultColor = [MBColorSpecs wd_mainTextColor];
    
    obj.loadingText = [self.class createAttributedTextWithText:@"加载中..."
                                                           font:defaultFont
                                                      textColor:defaultColor];
    
    obj.noDataTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
        return
        [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"暂无数据\n点击屏幕重试":@"暂无数据"
                                                 font:defaultFont
                                            textColor:defaultColor];
    };
    
    obj.noNetworkTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
        return
        [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"网络状态待提升\n点击屏幕重试":@"网络状态待提升"
                                                 font:defaultFont
                                            textColor:defaultColor];
    };
    
    obj.normalErrorTextGetter = ^(MBPageStatusKit *kit, BOOL viewTouchable){
        return
        [MBPageStatusKit createAttributedTextWithText:viewTouchable?@"Sorry, 貌似出错了\n点击屏幕重试":@"Sorry, 貌似出错了"
                                                 font:defaultFont
                                            textColor:defaultColor];
    };
    
    return obj;
}

+ (NSBundle *)bundle {
    return [NSBundle bundleForClass:[MBPageStatusKit class]];
}

@end
