//
//  TDOverlayDrawAnimation.m
//  tinyDict
//
//  Created by guangbool on 2017/5/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDOverlayDrawAnimation.h"

@implementation TDOverlayDrawAnimation

- (instancetype)init {
    if (self = [super init]) {
        _drawStyle = TDOverlayDrawAnimationDrawFromRight;
        _drawToAlignCenter = NO;
        _overlayAlphaWhenDrawOut = 1;
        _overlayAlphaWhenDrawAway = 0;
    }
    return self;
}

- (void)animate:(TDOverlayDrawAnimationContext *)context {
    if (!context) return;
    
    void(^safeAnimFinished)(BOOL) = ^(BOOL finished){
        if (context.animationFinishedHandler) {
            context.animationFinishedHandler(finished, context.fromVisible, context.toVisible);
        }
    };
    
    if (!context.fromVisible && context.toVisible && _drawView) {
        
        CGSize containerSize = _animationContainerSize;
        CGRect drawViewOriginFrame = _drawView.frame;
        
        switch (_drawStyle) {
            case TDOverlayDrawAnimationDrawFromRight:
            {
                _drawView.frame = CGRectMake(containerSize.width,
                                             CGRectGetMinY(drawViewOriginFrame),
                                             CGRectGetWidth(drawViewOriginFrame),
                                             CGRectGetHeight(drawViewOriginFrame));
                break;
            }
            case TDOverlayDrawAnimationDrawFromLeft:
            {
                _drawView.frame = CGRectMake(-CGRectGetWidth(drawViewOriginFrame),
                                             CGRectGetMinY(drawViewOriginFrame),
                                             CGRectGetWidth(drawViewOriginFrame),
                                             CGRectGetHeight(drawViewOriginFrame));
                break;
            }
            case TDOverlayDrawAnimationDrawFromTop:
            {
                _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                             -CGRectGetHeight(drawViewOriginFrame),
                                             CGRectGetWidth(drawViewOriginFrame),
                                             CGRectGetHeight(drawViewOriginFrame));
                break;
            }
            case TDOverlayDrawAnimationDrawFromBottom:
            {
                _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                             containerSize.height,
                                             CGRectGetWidth(drawViewOriginFrame),
                                             CGRectGetHeight(drawViewOriginFrame));
                break;
            }
        }
        
        if (_drawToAlignCenter) {
            CGPoint drawViewCenter = _drawView.center;
            switch (_drawStyle) {
                case TDOverlayDrawAnimationDrawFromRight:
                case TDOverlayDrawAnimationDrawFromLeft: {
                    _drawView.center = CGPointMake(drawViewCenter.x, containerSize.height/2);
                    break;
                }
                case TDOverlayDrawAnimationDrawFromTop:
                case TDOverlayDrawAnimationDrawFromBottom: {
                    _drawView.center = CGPointMake(containerSize.width/2, drawViewCenter.y);
                    break;
                }
            }
        }
        
        
        _overlayBackgroudView.alpha = self.overlayAlphaWhenDrawAway;
        [UIView animateWithDuration:context.duration animations:^{
            if (_drawToAlignCenter) {
                _drawView.center = CGPointMake(containerSize.width/2, containerSize.height/2);
            } else {
                switch (_drawStyle) {
                    case TDOverlayDrawAnimationDrawFromRight:
                    {
                        _drawView.frame = CGRectMake(containerSize.width - CGRectGetWidth(drawViewOriginFrame),
                                                     CGRectGetMinY(drawViewOriginFrame),
                                                     CGRectGetWidth(drawViewOriginFrame),
                                                     CGRectGetHeight(drawViewOriginFrame));
                        break;
                    }
                    case TDOverlayDrawAnimationDrawFromLeft:
                    {
                        _drawView.frame = CGRectMake(0,
                                                     CGRectGetMinY(drawViewOriginFrame),
                                                     CGRectGetWidth(drawViewOriginFrame),
                                                     CGRectGetHeight(drawViewOriginFrame));
                        break;
                    }
                    case TDOverlayDrawAnimationDrawFromTop:
                    {
                        _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                                     0,
                                                     CGRectGetWidth(drawViewOriginFrame),
                                                     CGRectGetHeight(drawViewOriginFrame));
                        break;
                    }
                    case TDOverlayDrawAnimationDrawFromBottom:
                    {
                        _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                                     containerSize.height - CGRectGetHeight(drawViewOriginFrame),
                                                     CGRectGetWidth(drawViewOriginFrame),
                                                     CGRectGetHeight(drawViewOriginFrame));
                        break;
                    }
                }
            }
            _overlayBackgroudView.alpha = self.overlayAlphaWhenDrawOut;
            
        } completion:^(BOOL finished) {
            safeAnimFinished(finished);
        }];
        
    } else if (context.fromVisible && !context.toVisible) {
        
        [UIView animateWithDuration:context.duration animations:^{
            CGSize containerSize = _animationContainerSize;
            CGRect drawViewOriginFrame = _drawView.frame;
            switch (_drawStyle) {
                case TDOverlayDrawAnimationDrawFromRight:
                {
                    _drawView.frame = CGRectMake(containerSize.width,
                                                 CGRectGetMinY(drawViewOriginFrame),
                                                 CGRectGetWidth(drawViewOriginFrame),
                                                 CGRectGetHeight(drawViewOriginFrame));
                    break;
                }
                case TDOverlayDrawAnimationDrawFromLeft:
                {
                    _drawView.frame = CGRectMake(-CGRectGetWidth(drawViewOriginFrame),
                                                 CGRectGetMinY(drawViewOriginFrame),
                                                 CGRectGetWidth(drawViewOriginFrame),
                                                 CGRectGetHeight(drawViewOriginFrame));
                    break;
                }
                case TDOverlayDrawAnimationDrawFromTop:
                {
                    _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                                 -CGRectGetHeight(drawViewOriginFrame),
                                                 CGRectGetWidth(drawViewOriginFrame),
                                                 CGRectGetHeight(drawViewOriginFrame));
                    break;
                }
                case TDOverlayDrawAnimationDrawFromBottom:
                {
                    _drawView.frame = CGRectMake(CGRectGetMinX(drawViewOriginFrame),
                                                 containerSize.height,
                                                 CGRectGetWidth(drawViewOriginFrame),
                                                 CGRectGetHeight(drawViewOriginFrame));
                    break;
                }
            }
            _overlayBackgroudView.alpha = self.overlayAlphaWhenDrawAway;
            
        } completion:^(BOOL finished) {
            safeAnimFinished(finished);
        }];
    }
}

@end


@implementation TDOverlayDrawAnimationContext

@end
