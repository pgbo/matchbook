//
//  MBRefreshKit+MBKit.m
//  matchbook
//
//  Created by guangbool on 2017/6/30.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBRefreshKit+MBKit.h"
#import "MBSpecs.h"

@implementation MBRefreshKit (MBKit)

+ (MBRefreshKit *)PageupKitWithActionBlock:(void(^)(MBRefreshKit *kit))actionBlock {
    MBRefreshKit *pageupKit = [[MBRefreshKit alloc] initWithRefreshBlock:actionBlock];
    
    NSDictionary *attrs = @{NSFontAttributeName:[MBFontSpecs small],
                            NSForegroundColorAttributeName:[MBColorSpecs wd_mainTextColor]};
    
    NSAttributedString *idleStateText = [[NSAttributedString alloc] initWithString:@"上翻至更早的比赛"
                                                                        attributes:attrs];
    NSAttributedString *refreshableStateText = [[NSAttributedString alloc] initWithString:@"松开上翻"
                                                                               attributes:attrs];
    NSAttributedString *refreshingStateText = [[NSAttributedString alloc] initWithString:@"上翻..."
                                                                              attributes:attrs];
    
    [pageupKit setIdleStateText:idleStateText
           refreshableStateText:refreshableStateText
            refreshingStateText:refreshingStateText];
    
    NSBundle *bundle = [self bundle];
    // set `loadingImages`
    NSMutableArray<UIImage *> *loadingImgs = [NSMutableArray<UIImage *> array];
    for (NSInteger i = 0; i <= 8; i++) {
        NSString *key = [NSString stringWithFormat:@"basket_ball%@", @(i)];
        UIImage *img = [UIImage imageNamed:key inBundle:bundle compatibleWithTraitCollection:nil];
        if (img) [loadingImgs addObject:img];
    }
    
    [pageupKit setIdleStateImages:loadingImgs refreshableStateImages:loadingImgs refreshingStateImages:loadingImgs];
    
    return pageupKit;
}

+ (NSBundle *)bundle {
    return [NSBundle bundleForClass:[MBRefreshKit class]];
}

@end
