//
//  UIViewController+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/7/14.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UIViewController+TDKit.h"

@implementation UIViewController (TDKit)

- (void)openURL:(NSURL *)url {
    UIResponder *responder = self;
    SEL sel = @selector(openURL:);
    while (responder != nil) {
        if ([responder isKindOfClass:[UIApplication class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 10) {
                
                SEL theSelector = @selector(openURL:options:completionHandler:);
                NSMethodSignature *aSignature = [UIApplication instanceMethodSignatureForSelector:theSelector];
                NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature:aSignature];
                [anInvocation setSelector:theSelector];
                [anInvocation setTarget:responder];
                [anInvocation setArgument:&url atIndex:2];
                NSDictionary *options = @{};
                [anInvocation setArgument:&options atIndex:3];
                [anInvocation invoke];
            } else {
                [responder performSelector:sel withObject:url];
            }
#pragma clang diagnostic pop
        }
        responder = [responder nextResponder];
    }
}

@end
