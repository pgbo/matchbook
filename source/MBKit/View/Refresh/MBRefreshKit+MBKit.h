//
//  MBRefreshKit+MBKit.h
//  matchbook
//
//  Created by guangbool on 2017/6/30.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <MBKit/MBKit.h>

@interface MBRefreshKit (MBKit)

/**
 上翻套件
 
 @param actionBlock 满足上翻条件时的程序调用
 @return 实例
 */
+ (MBRefreshKit *)PageupKitWithActionBlock:(void(^)(MBRefreshKit *kit))actionBlock;

@end
