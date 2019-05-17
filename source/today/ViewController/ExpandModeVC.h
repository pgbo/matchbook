//
//  ExpandModeVC.h
//  matchbook
//
//  Created by guangbool on 2017/7/19.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBKit/MBDataController.h>
#import <MBKit/OrderedDictionary.h>

@interface ExpandModeVC : UIViewController

// more 按钮点击 block
@property (nonatomic, copy) void(^moreBlock)(ExpandModeVC *vc);
// 节目选中的 block
@property (nonatomic, copy) void(^programDidSelectedBlock)(ExpandModeVC *vc, MBMatchProgram *program);

- (instancetype)initWithAllPrograms:(NSArray<MBMatchProgram*>*)programs;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (void)refreshLivePrograms:(NSArray<MBMatchProgram*> *)livePrgrams;

@end
