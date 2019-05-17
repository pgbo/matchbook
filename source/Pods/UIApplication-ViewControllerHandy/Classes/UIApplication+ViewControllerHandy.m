//
//  UIApplication+ViewControllerHandy.m
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UIApplication+ViewControllerHandy.h"

@implementation UIApplication (ViewControllerHandy)

- (UINavigationController *)presentedNavigationController {
    return [[self class] FindPresentedNavigationControllerForRoot:self.keyWindow.rootViewController];
}

+ (UINavigationController *)FindPresentedNavigationControllerForRoot:(UIViewController *)rootViewController {
    UIViewController *root = rootViewController;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    
    if([root isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVC = [((UITabBarController *)root).viewControllers objectAtIndex:((UITabBarController *)root).selectedIndex];
        return [self FindPresentedNavigationControllerForRoot:selectVC];
    } else if([root isKindOfClass:[UINavigationController class]]){
        return (UINavigationController *)root;
    }
    return nil;
}

- (UIViewController *)topmostPresentedViewController {
    UIViewController *root = self.keyWindow.rootViewController;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    return root;
}

+ (UIViewController *)FindDisplayingViewControllerForRoot:(UIViewController *)rootViewController {
    UIViewController *displayingViewController = nil;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarViewController = (UITabBarController *)rootViewController;
        UIViewController *selectVC = [tabBarViewController.viewControllers objectAtIndex:tabBarViewController.selectedIndex];
        displayingViewController = [[self class]FindDisplayingViewControllerForRoot:selectVC];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        displayingViewController = [(UINavigationController *)rootViewController topViewController];
    }
    return displayingViewController;
}

- (UIViewController *)topmostDisplayingViewController {
    UIViewController *topmostPresentedViewController = [self topmostPresentedViewController];
    return [[self class] FindDisplayingViewControllerForRoot:topmostPresentedViewController];
}

- (void)popOrDismissHighLevelViewControllerToViewController:(UIViewController *)viewController
                                                   animated:(BOOL)animated {
    if (!viewController)
        return;
    
    UINavigationController *navigationController = viewController.navigationController;
    if (navigationController) {
        if (navigationController.presentedViewController) {
            [navigationController dismissViewControllerAnimated:animated completion:nil];
        }
        if (navigationController.topViewController != viewController) {
            [navigationController popToViewController:viewController animated:animated];
        }
        
    } else {
        if (viewController.presentedViewController) {
            [viewController dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

@end
