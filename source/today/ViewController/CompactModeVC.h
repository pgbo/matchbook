//
//  CompactModeVC.h
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBKit/MBDataController.h>

@interface CompactModeVC : UIViewController

- (instancetype)initWithFocusedProgramNum:(NSUInteger)focusedProgramNum
                           liveProgramNum:(NSUInteger)liveProgramNum
                           displayProgram:(MBMatchProgram *)displayProgram;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (void)updateViewWithFocusedProgramNum:(NSUInteger)focusedProgramNum
                         liveProgramNum:(NSUInteger)liveProgramNum;

- (void)displayProgramItemIfNeed:(MBMatchProgram *)program;

@end
