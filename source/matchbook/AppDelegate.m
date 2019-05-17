//
//  AppDelegate.m
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "AppDelegate.h"
#import <MBKit/MBKit.h>
#import <SafariServices/SafariServices.h>
#import <UIApplication-ViewControllerHandy/UIApplication+ViewControllerHandy.h>
#import "DefaultNavigationController.h"
#import "MainViewController.h"

@interface AppDelegate ()

//@property (nonatomic) MBQueryStrategyManager *queryStrategyManager;
@property (nonatomic) Reachability *reachability;

@end

@implementation AppDelegate

+ (AppDelegate *)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configureAppearance];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    MainViewController *navRootVC = [[MainViewController alloc] init];
    DefaultNavigationController *nav = [[DefaultNavigationController alloc] initWithRootViewController:navRootVC];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
//    self.queryStrategyManager = [[MBQueryStrategyManager alloc] init];
//    [self.queryStrategyManager queryMatchList:({
//        MBQueryMatchListRequest *info = [[MBQueryMatchListRequest alloc] init];
//        info.shouldQueryScoreInfo = YES;
//        info;
//    }) handler:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
//        NSLog(@"\n\n\n\n");
//        NSLog(@"--------queryMatchList---------");
//        NSLog(@"status: %@", @(status));
//        NSLog(@"serviceProvider: %@", serviceProvider);
//        NSLog(@"results:\n\n %@\n\n", results);
//    }];
//
//    [self.queryStrategyManager queryMatchInfo:^NSDictionary<NSString *,NSString *> *(NSString *strategyImplCode) {
//        if ([strategyImplCode isEqualToString:MBQueryStrategy_ZB8QueryImplCode]) {
//            return @{@"id":@"99635", @"date":@"2017-06-16"};
//        }
//        return nil;
//    } handler:^(MBMatchScoreInfo *result, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
//        NSLog(@"\n\n\n\n");
//        NSLog(@"--------queryMatchInfo---------");
//        NSLog(@"status: %@", @(status));
//        NSLog(@"serviceProvider: %@", serviceProvider);
//        NSLog(@"result:\n%@", result);
//    }];
    
//    [self.queryStrategyManager queryProcessingMatchesWithHandler:^(NSArray<MBMatchScoreInfo *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
//        NSLog(@"\n\n\n\n");
//        NSLog(@"--------queryProcessingMatches---------");
//        NSLog(@"status: %@", @(status));
//        NSLog(@"serviceProvider: %@", serviceProvider);
//        NSLog(@"results:\n%@", results);
//    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [_reachability startNotifier];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [_reachability stopNotifier];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([self openUrlIfNeed:url]) {
        return YES;
    }
    return YES;
}

- (void)configureAppearance {
    
    // All view tint
    [[UIView appearance] setTintColor:[MBColorSpecs app_mainPositiveTint]];
    
    // NavigationBar
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[MBColorSpecs app_navigationText], NSFontAttributeName: [MBFontSpecs largeBold]};
//    [[UINavigationBar appearance] setBarTintColor:[MBColorSpecs app_themeTint]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[MBColorSpecs app_themeTint]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTintColor:[MBColorSpecs app_navigationText]];
    
    // UIBarButtonItem
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[MBColorSpecs app_mainPositiveTint], NSFontAttributeName: [MBFontSpecs regular]} forState:UIControlStateNormal];
    
    // Table section header && footer
    UILabel *tableSectionHeaderFooterAppearance
    = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]];
    tableSectionHeaderFooterAppearance.textColor = [MBColorSpecs app_minorTextColor];
    tableSectionHeaderFooterAppearance.font = [MBFontSpecs regular];
}

- (BOOL)openUrlIfNeed:(NSURL *)url {
    if (!url) return NO;
    
    if ([url.host isEqualToString:@"detail"]) {
        // 节目详情
        NSDictionary *queryParams = [url queryWrapToDictionary];
        NSString *detail_link = [queryParams[@"link"] stringByURLDecode];
        NSURL *detailUrl = [NSURL URLWithString:detail_link];
        if (detailUrl) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:detailUrl entersReaderIfAvailable:YES];
            [[UIApplication sharedApplication].topmostPresentedViewController presentViewController:safariVC animated:YES completion:nil];
        }
        return YES;
    }
    
    return NO;
}

@end
