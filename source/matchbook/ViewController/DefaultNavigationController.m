//
//  DefaultNavigationController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "DefaultNavigationController.h"

@interface DefaultNavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (nonatomic,weak)  UIViewController* currentShowVC;   //当前操作VC

@end

@implementation DefaultNavigationController

-(id)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.delegate = self;
        }
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backIc = [UIImage imageNamed:@"back_ic"];
    [self.navigationBar setBackIndicatorImage:backIc];
    [self.navigationBar setBackIndicatorTransitionMaskImage:backIc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"willShowViewController: %@", NSStringFromClass(viewController.class));
//    NSLog(@"navigationController.viewControllers:\n%@", navigationController.viewControllers);
//    NSLog(@"navigationController.topViewController: %@", NSStringFromClass(navigationController.topViewController.class));
    
    NSArray<UIViewController *> *stack = navigationController.viewControllers;
    if ([navigationController.topViewController isEqual:viewController] && stack.count > 1) {
        // push a new view controller
        // make the points to page's back title blank
        // solution detail: https://movieos.org/2013/63401593182/
        UIViewController *backVC = stack[stack.count - 2];
        backVC.navigationItem.backBarButtonItem
            = [[UIBarButtonItem alloc] initWithTitle:@""
                                               style:UIBarButtonItemStylePlain
                                              target:nil
                                              action:nil];
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = nil;
    else
        self.currentShowVC = viewController;
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.currentShowVC == self.topViewController);
    }
    return YES;
}

@end
