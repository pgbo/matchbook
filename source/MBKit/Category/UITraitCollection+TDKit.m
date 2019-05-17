//
//  UITraitCollection+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/4/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UITraitCollection+TDKit.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIDevice+TDKit.h"

@implementation UITraitCollection (TDKit)

- (BOOL)isFeedbackHardwareSupportForCurrentMachine {
    static NSArray<NSString *> *disableMachines = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disableMachines = @[@"iPhone1,1", @"iPhone1,2", @"iPhone2,1", @"iPhone3,1", @"iPhone3,2", @"iPhone3,3", @"iPhone4,1", @"iPhone5,1", @"iPhone5,2", @"iPhone5,3", @"iPhone5,4", @"iPhone6,1", @"iPhone6,2", @"iPhone7,1", @"iPhone7,2", @"iPhone8,1", @"iPhone8,2", @"iPhone8,4"];
    });
    
    NSString *machineModel = [UIDevice currentDevice].machineModel;
    return ([machineModel hasPrefix:@"iPhone"] && ![disableMachines containsObject:machineModel]);
}

- (BOOL)tapticPeekVibrate {
    if (self.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if ([UIDevice systemVersion] >= 10.0 && [self isFeedbackHardwareSupportForCurrentMachine]) {
            UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [feedback prepare];
            [feedback impactOccurred];
            return YES;
        } else {
            // all sound services, reference http://iphonedevwiki.net/index.php/AudioServices
            AudioServicesPlaySystemSoundWithCompletion(1519, nil);
        }
    }
    return NO;
}

@end
