//
//  AppDelegate.h
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBKit/Reachability.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) Reachability *reachability;

+ (AppDelegate *)instance;

@end

