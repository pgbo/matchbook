//
//  LFPageInformationContextAnimationing.h
//  LFPageInformationKitDemo
//
//  Created by guangbool on 16/6/1.
//  Copyright © 2016年 guangbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LFPageInformationContextAnimationing <NSObject>

- (UIView *)lfpi_containerView;

- (BOOL)lfpi_fromVisible;

- (BOOL)lfpi_toVisible;

- (void(^)(BOOL didComplete))lfpi_completeAnimationBlock;

@end
