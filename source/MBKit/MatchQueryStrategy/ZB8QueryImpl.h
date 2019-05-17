//
//  ZB8QueryImpl.h
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBQueryStrategy.h"

// 方法`queryMatchInfo:handler:`的请求信息中的键:date，形式 yyyy-MM-dd
static NSString *const ZB8QueryImplQueryMatchInfoRequestKey_date = @"date";
// 方法`queryMatchInfo:handler:`的请求信息中的键:id
static NSString *const ZB8QueryImplQueryMatchInfoRequestKey_id = @"id";

@interface ZB8QueryImpl : NSObject <MBQueryStrategy>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithQueryMatchesUrl:(NSString *)matchesUrl
                   processingMatchesUrl:(NSString *)processingMatchesUrl
                           matchInfoUrl:(NSString *)matchInfoUrl
                         dataParseJsUrl:(NSString *)dataParseJsUrl;


@end
