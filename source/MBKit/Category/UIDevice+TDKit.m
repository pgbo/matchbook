//
//  UIDevice+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/6/1.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UIDevice+TDKit.h"
#include <sys/sysctl.h>

@implementation UIDevice (TDKit)

+ (double)systemVersion {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

@end
