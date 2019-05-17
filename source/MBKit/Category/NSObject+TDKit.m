//
//  NSObject+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "NSObject+TDKit.h"
#import <objc/runtime.h>

@implementation NSObject (TDKit)

- (void)setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAssociateWeakValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

- (id)getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

@end
