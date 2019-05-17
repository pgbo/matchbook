//
//  NSObject+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TDKit)

#pragma mark - Associate value
///=============================================================================
/// @name Associate value
///=============================================================================

/**
 Associate one object to `self`, as if it was a strong property (strong, nonatomic).
 
 @param value   The object to associate.
 @param key     The pointer to get value from `self`.
 */
- (void)setAssociateValue:(nullable id)value withKey:(void *_Nonnull)key;

/**
 Associate one object to `self`, as if it was a weak property (week, nonatomic).
 
 @param value  The object to associate.
 @param key    The pointer to get value from `self`.
 */
- (void)setAssociateWeakValue:(nullable id)value withKey:(void *_Nonnull)key;

/**
 Get the associated value from `self`.
 
 @param key The pointer to get value from `self`.
 */
- (nullable id)getAssociatedValueForKey:(void *_Nonnull)key;

/**
 Remove all associated values.
 */
- (void)removeAssociatedValues;

@end
