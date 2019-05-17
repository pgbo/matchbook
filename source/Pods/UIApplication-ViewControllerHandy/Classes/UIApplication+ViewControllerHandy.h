//
//  UIApplication+ViewControllerHandy.h
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (ViewControllerHandy)

/*
 * Get the presented Navigation controller
 */
- (UINavigationController *)presentedNavigationController;
/*
 * Get the presented view controller
 */
- (UIViewController *)topmostPresentedViewController;
/*
 * Get displaying view controller
 */
- (UIViewController *)topmostDisplayingViewController;
/*
 * Pop or dismiss the view controllers which level is higher than the given viewController
 *  @param viewController given viewController
 *  @param animated       animated
 */
- (void)popOrDismissHighLevelViewControllerToViewController:(UIViewController *)viewController
                                                   animated:(BOOL)animated;

@end
