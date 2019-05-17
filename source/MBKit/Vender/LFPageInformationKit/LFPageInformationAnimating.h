//
//  LFPageInformationAnimating.h
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LFPageInformationContextAnimationing.h"

@protocol LFPageInformationAnimating <NSObject>

/**
 *  Asks your animator object for the duration (in seconds) of the animation.
 *
 *  @param animationContext animationContext
 *
 *  @return The duration, in seconds, of your custom transition animation.
 */
- (NSTimeInterval)lfpi_animationDuration:(id<LFPageInformationContextAnimationing>)animationContext;

/**
 *  Tells your animator object to perform the animations.
 *
 *  @param animationContext Context of animation 
 */
- (void)lfpi_animate:(id<LFPageInformationContextAnimationing>)animationContext;

@end
