//
//  UIDevice+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/6/1.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (TDKit)

/// Device system version (e.g. 8.1)
+ (double)systemVersion;

/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModel;

@end
