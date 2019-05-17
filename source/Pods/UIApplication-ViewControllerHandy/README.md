# UIApplication-ViewControllerHandy
Handy methods for UIViewController related to UIApplication


```
/*
 * Get the presented Navigation controller
 */
- (UINavigationController *)presentedNavigationController
```
```
/*
 * Get the presented view controller
 */
- (UIViewController *)topmostPresentedViewController
```
```
/*
 * Get displaying view controller
 */
- (UIViewController *)topmostDisplayingViewController
```
```
/*
 * Pop or dismiss the view controllers which level is higher than the given viewController
 */
- (void)popOrDismissHighLevelViewControllerToViewController:(UIViewController *)viewController
                                                   animated:(BOOL)animated
```
 
