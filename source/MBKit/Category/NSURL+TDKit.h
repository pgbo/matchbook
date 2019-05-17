//
//  NSURL+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (TDKit)


/**
 将 url 的 query 部分包装成字典

 @return 字典
 */
- (NSDictionary *)queryWrapToDictionary;

@end
