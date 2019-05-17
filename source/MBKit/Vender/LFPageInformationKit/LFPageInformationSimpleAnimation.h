//
//  LFPageInformationSimpleAnimation.h
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LFPageInformationDisplayItem.h"

/**
 *  简单的动画，实现了对`informationDisplayView`在`显示`和`隐藏`切换时 alpha 的动画
 */
@interface LFPageInformationSimpleAnimation : NSObject <LFPageInformationAnimating>

/**
 *  信息展示视图
 */
@property (nonatomic) UIView *informationDisplayView;

@end
