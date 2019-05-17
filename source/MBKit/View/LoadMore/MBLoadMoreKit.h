//
//  MBLoadMoreKit.h
//  matchbook
//
//  Created by guangbool on 2017/6/28.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLoadMoreKit : NSObject

/**
 *  Whether loading or not
 */
@property (nonatomic, readonly) BOOL isLoading;

/**
 *  Whether auto loading when scroll to and stay at bottom
 */
@property (nonatomic) BOOL autoLoadWhenScrollToBottom;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithLoadBlock:(void(^)(MBLoadMoreKit *kit))loadBlock;


/**
 Configure the text under diffrent state.
 
 @param idleStateText The text under idle state.
 @param loadableStateText The text under loadable state.
 @param loadingStateText The text under loading state.
 */
- (void)setIdleStateText:(NSAttributedString *)idleStateText
       loadableStateText:(NSAttributedString *)loadableStateText
        loadingStateText:(NSAttributedString *)loadingStateText;

/**
 Configure the animated images under diffrent state.
 
 @param idleStateImages The animated images under idle state.
 @param loadableStateImages The animated images under loadable state.
 @param loadingStateImages The animated images under loading state.
 */
- (void)setIdleStateImages:(NSArray<UIImage *> *)idleStateImages
       loadableStateImages:(NSArray<UIImage *> *)loadableStateImages
        loadingStateImages:(NSArray<UIImage *> *)loadingStateImages;

/**
 *  Install load more footer in a particular scroll view
 */
- (void)installToScrollView:(UIScrollView *)scrollView;

/**
 *  Uninstall the load more footer from host view
 */
- (void)uninstall;

/**
 *  Finish loading
 */
- (void)finishLoading;

@end
