//
//  NSURL+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/5/19.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "NSURL+TDKit.h"

@implementation NSURL (TDKit)

- (NSDictionary *)queryWrapToDictionary {
    if ([self query].length) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSString *pattern = @"([^=]+)=(.*?)&";
        NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                               options:kNilOptions
                                                                                 error:nil];
        NSString *query = [[self query] stringByAppendingString:@"&"];
        NSArray *matches = [expression matchesInString:query
                                               options:NSMatchingReportCompletion
                                                 range:NSMakeRange(0, [query length])];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *obj, NSUInteger idx, BOOL *stop) {
            if ([obj numberOfRanges] >= 3) {
                [result setObject:[query substringWithRange:[obj rangeAtIndex:2]]
                           forKey:[query substringWithRange:[obj rangeAtIndex:1]]];
            }
        }];
        return result;
    }
    return nil;
}

@end
