//
//  MBPageStatusKit+MBKit.h
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBPageStatusKit.h"

@interface MBPageStatusKit (MBKit)

/**
 App 端默认全页状态套件

 @param containerView 容器视图
 @return 实例
 */
+ (MBPageStatusKit *)appDefaultWithContainer:(UIView *)containerView;

/**
 Widget 端默认全页状态套件
 
 @param containerView 容器视图
 @return 实例
 */
+ (MBPageStatusKit *)widgetDefaultWithContainer:(UIView *)containerView;

@end
