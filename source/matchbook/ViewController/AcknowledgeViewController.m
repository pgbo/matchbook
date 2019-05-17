//
//  AcknowledgeViewController.m
//  tinyDict
//
//  Created by 彭光波 on 2017/5/30.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AcknowledgeViewController.h"
#import <MBKit/MBSpecs.h>
#import <MBKit/OrderedDictionary.h>
#import <SafariServices/SafariServices.h>

static MutableOrderedDictionary<NSString *, NSString *> *AcknowledgeItems;

@interface AcknowledgeViewController ()

@end

@implementation AcknowledgeViewController

+ (void)initialize {
    AcknowledgeItems = [[MutableOrderedDictionary alloc] init];
    AcknowledgeItems[@"Masonry"] = @"https://github.com/SnapKit/Masonry";
    AcknowledgeItems[@"MMWormhole"] = @"https://github.com/mutualmobile/MMWormhole";
    AcknowledgeItems[@"Reachability"] = @"https://github.com/tonymillion/Reachability";
    AcknowledgeItems[@"OrderedDictionary"] = @"https://github.com/nicklockwood/OrderedDictionary";
    AcknowledgeItems[@"UIButton-SSEdgeInsets"] = @"https://github.com/sinofake/UIButton-SSEdgeInsets";
    AcknowledgeItems[@"YYImage"] = @"https://github.com/ibireme/YYImage";
    AcknowledgeItems[@"BOOLoadMoreController"] = @"https://github.com/pgbo/BOOLoadMoreController";
    AcknowledgeItems[@"BOOLRefreshController"] = @"https://github.com/pgbo/BOOLRefreshController";
    AcknowledgeItems[@"LFPageInformationKit"] = @"https://github.com/pgbo/LFPageInformationKit";
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"感谢以下项目的付出";
    
    self.tableView.backgroundColor = [MBColorSpecs app_pageBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [MBColorSpecs app_separator];
}

#pragma mark - Table view data source

- (UITableViewCell *)cellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(cellDequeued));
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [MBFontSpecs large];
        cell.textLabel.textColor = [MBColorSpecs app_mainTextColor];
        cell.textLabel.numberOfLines = 1;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AcknowledgeItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellDequeued];
    cell.textLabel.text = AcknowledgeItems.allKeys[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *url = AcknowledgeItems[indexPath.row];
    if (url.length > 0) {
        [self presentViewController:[[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]] animated:YES
                         completion:nil];
    }
}

@end
