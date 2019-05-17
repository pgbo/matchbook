//
//  MBLoadMoreKit+MBKit.m
//  matchbook
//
//  Created by guangbool on 2017/7/6.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBLoadMoreKit+MBKit.h"
#import "MBSpecs.h"

@implementation MBLoadMoreKit (MBKit)

+ (MBLoadMoreKit *)defaultLoadMoreKitWithActionBlock:(void(^)(MBLoadMoreKit *kit))actionBlock {
    MBLoadMoreKit *loadMoreKit = [[MBLoadMoreKit alloc] initWithLoadBlock:actionBlock];
    
    NSDictionary *attrs = @{NSFontAttributeName:[MBFontSpecs small],
                            NSForegroundColorAttributeName:[MBColorSpecs wd_mainTextColor]};
    
    NSAttributedString *idleStateText = [[NSAttributedString alloc] initWithString:@"上拉加载更多"
                                                                        attributes:attrs];
    NSAttributedString *loadableStateText = [[NSAttributedString alloc] initWithString:@"松开加载"
                                                                            attributes:attrs];
    NSAttributedString *loadingStateText = [[NSAttributedString alloc] initWithString:@"加载..."
                                                                           attributes:attrs];
    
    [loadMoreKit setIdleStateText:idleStateText
                loadableStateText:loadableStateText
                 loadingStateText:loadingStateText];
    
    NSBundle *bundle = [self bundle];
    // set `loadingImages`
    NSMutableArray<UIImage *> *loadingImgs = [NSMutableArray<UIImage *> array];
    for (NSInteger i = 0; i <= 8; i++) {
        NSString *key = [NSString stringWithFormat:@"basket_ball%@", @(i)];
        UIImage *img = [UIImage imageNamed:key inBundle:bundle compatibleWithTraitCollection:nil];
        if (img) [loadingImgs addObject:img];
    }
    
    [loadMoreKit setIdleStateImages:loadingImgs loadableStateImages:loadingImgs loadingStateImages:loadingImgs];
    
    return loadMoreKit;
}

+ (NSBundle *)bundle {
    return [NSBundle bundleForClass:[MBLoadMoreKit class]];
}

@end
