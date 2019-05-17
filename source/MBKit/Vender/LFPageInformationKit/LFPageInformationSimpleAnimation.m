//
//  LFPageInformationSimpleAnimation.m
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import "LFPageInformationSimpleAnimation.h"

@implementation LFPageInformationSimpleAnimation

- (NSTimeInterval)lfpi_animationDuration:(id<LFPageInformationContextAnimationing>)animationContext
{
    return 0.3;
}

- (void)lfpi_animate:(id<LFPageInformationContextAnimationing>)animationContext
{
    if (!animationContext.lfpi_fromVisible && animationContext.lfpi_toVisible && _informationDisplayView) {
        
        _informationDisplayView.alpha = 0;

        [UIView animateWithDuration:0.3 animations:^{
            _informationDisplayView.alpha = 1;
        } completion:^(BOOL finished) {
            if (animationContext.lfpi_completeAnimationBlock) {
                animationContext.lfpi_completeAnimationBlock(finished);
            }
        }];
        
    } else if (animationContext.lfpi_fromVisible && !animationContext.lfpi_toVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            _informationDisplayView.alpha = 0;
        } completion:^(BOOL finished) {
            if (animationContext.lfpi_completeAnimationBlock) {
                animationContext.lfpi_completeAnimationBlock(finished);
            }
        }];
    }
}

@end
