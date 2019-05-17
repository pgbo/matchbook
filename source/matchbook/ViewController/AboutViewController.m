//
//  AboutViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AboutViewController.h"
#import <MBKit/MBSpecs.h>
#import "AcknowledgeViewController.h"

@interface AboutViewController ()

@property (nonatomic, weak) IBOutlet UILabel *sloganLabel;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButn;
@property (nonatomic, weak) IBOutlet UIButton *thanksButn;

@property (nonatomic) NSUInteger didLayoutSubviewsNum;

@end

@implementation AboutViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([AboutViewController class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于";
    self.view.backgroundColor = [UIColor whiteColor];
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _didLayoutSubviewsNum ++;
    if (_didLayoutSubviewsNum == 1) {
        
        // Do animation
        CGRect sloganFrame = self.sloganLabel.frame;
        self.sloganLabel.frame = CGRectMake(-sloganFrame.size.width, sloganFrame.origin.y, sloganFrame.size.width, sloganFrame.size.height);
        self.sloganLabel.alpha = 0;
        
        [UIView animateWithDuration:1.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.sloganLabel.frame = sloganFrame;
                             self.sloganLabel.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (IBAction)share:(id)sender {
    NSString *shareTitle = @"比赛目录 - 赛事比分先知道";
    UIImage *shareImg = [UIImage imageNamed:@"logo_ic_round"];
    NSURL *appShareUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/id1257797109"];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[shareImg, shareTitle, appShareUrl] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)thanks:(id)sender {
    [self.navigationController pushViewController:[[AcknowledgeViewController alloc] init] animated:YES];
}

@end
