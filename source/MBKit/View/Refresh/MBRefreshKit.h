//
//  MBRefreshKit.h
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBRefreshKit : NSObject

/**
 *  Whether refreshing or not
 */
@property (nonatomic, readonly) BOOL isRefreshing;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRefreshBlock:(void(^)(MBRefreshKit *kit))refreshBlock;


/**
 Configure the text under diffrent state.

 @param idleStateText The text under idle state.
 @param refreshableStateText The text under refreshable state.
 @param refreshingStateText The text under refreshing state.
 */
- (void)setIdleStateText:(NSAttributedString *)idleStateText
    refreshableStateText:(NSAttributedString *)refreshableStateText
     refreshingStateText:(NSAttributedString *)refreshingStateText;

/**
 Configure the animated images under diffrent state.
 
 @param idleStateImages The animated images under idle state.
 @param refreshableStateImages The animated images under refreshable state.
 @param refreshingStateImages The animated images under refreshing state.
 */
- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages
    refreshableStateImages:(NSArray<UIImage *> *)refreshableStateImages
     refreshingStateImages:(NSArray<UIImage *> *)refreshingStateImages;

/**
 *  Install refresh header in a particular scroll view
 */
- (void)installToScrollView:(UIScrollView *)scrollView;

/**
 *  Uninstall the refresh header from host view
 */
- (void)uninstall;

/**
 *  Finish refreshing
 */
- (void)finishRefreshing;

@end
