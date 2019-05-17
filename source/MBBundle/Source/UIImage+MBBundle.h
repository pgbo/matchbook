//
//  UIImage+MBBundle.h
//  matchbook
//
//  Created by guangbool on 2017/6/26.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MBBundle)

// 主队比分视图的背景图
+ (UIImage *)homeTeamScoreViewBackgroudImage;
// 客队比分视图的背景图
+ (UIImage *)visitTeamScoreViewBackgroudImage;

// 正在播出的标示视图背景图
+ (UIImage *)liveMarkViewBackgroudImage;
// 已关注的标示视图背景图
+ (UIImage *)focusedMarkViewBackgroudImage;

@end
