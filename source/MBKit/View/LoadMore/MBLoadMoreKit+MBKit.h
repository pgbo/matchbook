//
//  MBLoadMoreKit+MBKit.h
//  matchbook
//
//  Created by guangbool on 2017/7/6.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBLoadMoreKit.h"

@interface MBLoadMoreKit (MBKit)

/**
 加载更多套件
 
 @param actionBlock 加载更多调用
 @return 实例
 */
+ (MBLoadMoreKit *)defaultLoadMoreKitWithActionBlock:(void(^)(MBLoadMoreKit *kit))actionBlock;

@end
