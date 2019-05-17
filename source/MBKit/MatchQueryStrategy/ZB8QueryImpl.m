//
//  ZB8QueryImpl.m
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "ZB8QueryImpl.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Reachability.h"
#import "MBQueryStrategyMacros.h"

static NSString *ZB8QueryImplProvider = @"直播吧";

@interface ZB8QueryImpl ()

@property (nonatomic, copy) NSString *matchesUrl;
@property (nonatomic, copy) NSString *processingMatchesUrl;
@property (nonatomic, copy) NSString *matchInfoUrl;
@property (nonatomic, copy) NSString *dataParseJsUrl;

@property (nonatomic, copy) NSString *obtainDataParseJsContentToken;
// data缓存
@property (nonatomic, copy) NSString *cachedDataParseJsContent;

@property (nonatomic) Reachability *reachability;

@end

@implementation ZB8QueryImpl

+ (instancetype)strategyWithConfig:(NSDictionary *)config {
    NSString *url1 = config[MBQueryStrategyConfigKey__query_matches_url];
    NSString *url2 = config[MBQueryStrategyConfigKey__query_processing_matches_url];
    NSString *url3 = config[MBQueryStrategyConfigKey__query_match_info_url];
    NSString *url4 = config[MBQueryStrategyConfigKey__data_parse_js_url];
    return [[ZB8QueryImpl alloc] initWithQueryMatchesUrl:url1
                                    processingMatchesUrl:url2
                                            matchInfoUrl:url3
                                          dataParseJsUrl:url4];
}

- (instancetype)initWithQueryMatchesUrl:(NSString *)matchesUrl
                   processingMatchesUrl:(NSString *)processingMatchesUrl
                           matchInfoUrl:(NSString *)matchInfoUrl
                         dataParseJsUrl:(NSString *)dataParseJsUrl {
    if (self = [super init]) {
        self.obtainDataParseJsContentToken = @"obtainDataParseJsContentToken";
        self.matchesUrl = matchesUrl;
        self.processingMatchesUrl = processingMatchesUrl;
        self.matchInfoUrl = matchInfoUrl;
        self.dataParseJsUrl = dataParseJsUrl;
        
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    [_reachability stopNotifier];
}

NSArray<MBMatchProgram *>* parseZB8MatchListFromHtml(NSString *htmlContent,
                                                     NSString *parseJSScript) {
    
    if (!htmlContent || htmlContent.length == 0) return nil;
    if (parseJSScript.length == 0) return nil;
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"exception: %@", exception);
    };
    
    NSString *optText = [htmlContent stringByReplacingOccurrencesOfString:@"[\r\n\t]"
                                                               withString:@""
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, htmlContent.length)];
    [ctx evaluateScript:parseJSScript];
    JSValue *parseMatchList_func = [ctx objectForKeyedSubscript:@"parseMatchList"];
    JSValue *mlist = [parseMatchList_func callWithArguments:@[optText]];
    NSArray *results = mlist.toArray;
    if (!results) return nil;
    
    NSMutableArray<MBMatchProgram *> *programs = [NSMutableArray<MBMatchProgram *> array];
    for (NSDictionary *item in results) {
        MBMatchProgram *program = [[MBMatchProgram alloc] initWithDictiotnary:item];
        if (program) [programs addObject:program];
    }
    return programs;
}

NSArray<MBMatchProgram*>* parseZB8ProcessingMatchesFromJSON(NSString *jsonText,
                                                              NSString *parseJSScript) {
    if (!jsonText || jsonText.length == 0) return nil;
    if (parseJSScript.length == 0) return nil;
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"exception: %@", exception);
    };
    
    [ctx evaluateScript:parseJSScript];
    JSValue *parseMatchList_func = [ctx objectForKeyedSubscript:@"parseProcessingMatches"];
    JSValue *mlist = [parseMatchList_func callWithArguments:@[jsonText]];
    NSArray *results = mlist.toArray;
    if (!results) return nil;
    
    NSMutableArray<MBMatchProgram *> *infos = [NSMutableArray<MBMatchProgram *> array];
    for (NSDictionary *item in results) {
        MBMatchProgram *info = [[MBMatchProgram alloc] initWithDictiotnary:item];
        if (info) [infos addObject:info];
    }
    return infos;
}

MBMatchProgram* parseZB8MatchSocreInfoFromJSON(NSString *jsonText,
                                                 NSString *parseJSScript) {
    if (!jsonText || jsonText.length == 0) return nil;
    if (parseJSScript.length == 0) return nil;
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"exception: %@", exception);
    };
    
    [ctx evaluateScript:parseJSScript];
    JSValue *parseMatchList_func = [ctx objectForKeyedSubscript:@"parseMatchItemInfo"];
    JSValue *mlist = [parseMatchList_func callWithArguments:@[jsonText]];
    NSDictionary *result = mlist.toDictionary;
    if (!result) return nil;
    
    MBMatchProgram *info = [[MBMatchProgram alloc] initWithDictiotnary:result];
    return info;
}

/**
 获取正在进行的比赛节目信息
 */
+ (NSArray<MBMatchProgram *> *)queryProcessingMatchesWithUrl:(NSString *)queryUrl
                                             dataParseJSScript:(NSString *)dataParseJSScript {
    
    NSAssert(queryUrl.length != 0, @"`queryUrl` can't be empty");
    
    NSError *error;
    NSString *jsonContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:queryUrl] encoding:NSUTF8StringEncoding error:&error];
    if (error || jsonContent.length == 0) {
        return nil;
    }
    NSArray<MBMatchProgram *> *results = parseZB8ProcessingMatchesFromJSON(jsonContent, dataParseJSScript);
    
    return results;
}

- (NSString *)obtainDataParseJsContent {
    NSString *content = nil;
    @synchronized (self.obtainDataParseJsContentToken) {
        content = self.cachedDataParseJsContent;
        NSString *jsUrl = self.dataParseJsUrl;
        if (content.length == 0 && jsUrl.length > 0) {
            NSError *error;
            content = [NSString stringWithContentsOfURL:[NSURL URLWithString:jsUrl] encoding:NSUTF8StringEncoding error:&error];
            self.cachedDataParseJsContent = content;
        }
    }
    return content;
}

#pragma mark - MBQueryStrategy

- (void)queryMatchList:(MBQueryMatchListRequest *)reqInfo
               handler:(MBQueryMatchListCompleteHandler)handler {
    
    MBQueryMatchListCompleteHandler safeHandler = ^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider){
        if (handler) {
            handler(results, status, serviceProvider?:ZB8QueryImplProvider);
        }
    };
    
    NSString *queryMatchesUrl = self.matchesUrl;
    NSString *queryProcessingMatchesUrl = self.processingMatchesUrl;
    NSAssert(queryMatchesUrl.length != 0, @"`matchesUrl` can't be empty");
    
    if (![_reachability isReachable]) {
        safeHandler(nil, MBQueryMatchInfoNoNetwork, nil);
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf) return;
        NSString *parseJSScript = [weakSelf obtainDataParseJsContent];
        
        NSError *error;
        NSString *htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:queryMatchesUrl] encoding:NSUTF8StringEncoding error:&error];
        if (error || htmlContent.length == 0) {
            safeHandler(nil, MBQueryMatchInfoFail, nil);
            return;
        }
        NSArray<MBMatchProgram *> *results = parseZB8MatchListFromHtml(htmlContent, parseJSScript);
        
        if (results.count > 0 && reqInfo.shouldQueryScoreInfo) {
            // 获取比分和状态等信息
            NSArray<MBMatchProgram *> *processingMatches
                = [ZB8QueryImpl queryProcessingMatchesWithUrl:queryProcessingMatchesUrl
                                            dataParseJSScript:parseJSScript];
            for (MBMatchProgram *scoreInfo in processingMatches){
                for (MBMatchProgram *prog in results){
                    if ([scoreInfo.program_id isEqualToString:prog.program_id]) {
                        [prog fillPropertiesWithAnother:scoreInfo ignoreUnkownValueFields:YES];
                        break;
                    }
                }
            }
        }
        
        safeHandler(results, results?MBQueryMatchInfoSuccess:MBQueryMatchInfoFail, nil);
    });
}

- (void)queryLivingMatchesWithHandler:(MBQueryLivingMatchesCompleteHandler)handler {
    
    MBQueryLivingMatchesCompleteHandler safeHandler = ^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider){
        if (handler) {
            handler(results, status, serviceProvider?:ZB8QueryImplProvider);
        }
    };
    
    if (![_reachability isReachable]) {
        safeHandler(nil, MBQueryMatchInfoNoNetwork, nil);
        return;
    }
    
    NSString *queryProcessingMatchesUrl = self.processingMatchesUrl;
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf) return;
        NSString *parseJSScript = [weakSelf obtainDataParseJsContent];
        
        NSArray<MBMatchProgram *> *results = [ZB8QueryImpl queryProcessingMatchesWithUrl:queryProcessingMatchesUrl
                                                                       dataParseJSScript:parseJSScript];
        
        safeHandler(results, results?MBQueryMatchInfoSuccess:MBQueryMatchInfoFail, nil);
    });
}

- (void)queryMatchInfo:(NSDictionary<NSString*,
                        NSString*>*(^)(NSString *strategyImplCode))requestInfoBlock
               handler:(MBQueryMatchInfoCompleteHandler)handler {
    
    MBQueryMatchInfoCompleteHandler safeHandler = ^(MBMatchProgram *result, MBQueryMatchInfoStatus status, NSString *serviceProvider){
        if (handler) {
            handler(result, status, serviceProvider?:ZB8QueryImplProvider);
        }
    };
    
    NSString *program_id = nil;
    NSString *date = nil;
    if (requestInfoBlock) {
        NSDictionary *reqInfo = requestInfoBlock(MBQueryStrategy_ZB8QueryImplCode);
        program_id = reqInfo[ZB8QueryImplQueryMatchInfoRequestKey_id];
        date = reqInfo[ZB8QueryImplQueryMatchInfoRequestKey_date];
    }
    if (program_id) program_id = @"";
    
    NSString *queryMatchUrl = self.matchInfoUrl;
    NSAssert(queryMatchUrl.length != 0, @"`matchInfoUrl` can't be empty");
    
    if (![_reachability isReachable]) {
        safeHandler(nil, MBQueryMatchInfoNoNetwork, nil);
        return;
    }
    
    queryMatchUrl = [queryMatchUrl stringByReplacingOccurrencesOfString:@"{date}"
                                                             withString:date];
    queryMatchUrl = [queryMatchUrl stringByReplacingOccurrencesOfString:@"{id}"
                                                             withString:program_id];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf) return;
        NSString *parseJSScript = [weakSelf obtainDataParseJsContent];
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:queryMatchUrl] options:0 error:&error];
        if (error || !data) {
            safeHandler(nil, MBQueryMatchInfoFail, nil);
            return;
        }
        NSString *jsonContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        MBMatchProgram *result = parseZB8MatchSocreInfoFromJSON(jsonContent, parseJSScript);
        
        safeHandler(result, MBQueryMatchInfoSuccess, nil);
    });
}

@end
