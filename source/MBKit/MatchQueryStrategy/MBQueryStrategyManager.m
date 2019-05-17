//
//  MBQueryStrategyManager.m
//  matchbook
//
//  Created by guangbool on 2017/6/16.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBQueryStrategyManager.h"
#import "MBQueryStrategyMacros.h"
#import "ZB8QueryImpl.h"
#import "Reachability.h"

@interface MBQueryStrategyManager ()

@property (nonatomic) Reachability *reachability;

@property (nonatomic, copy) NSDictionary *config;
@property (nonatomic, copy) NSString *updateConfigToken;
@property (nonatomic, copy) NSString *obtainStrategyToken;

// 缓存 strategy, key 的形式为 version__implcode
@property (nonatomic) NSMutableDictionary<NSString *, id<MBQueryStrategy>> *cachedStrategies;

@end

@implementation MBQueryStrategyManager

- (instancetype)init {
    if (self = [super init]) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        self.updateConfigToken = @"updateConfigToken";
        self.obtainStrategyToken = @"obtainStrategyToken";
    }
    return self;
}

+ (instancetype)strategyWithConfig:(NSDictionary *)config {
    MBQueryStrategyManager *instance = [[MBQueryStrategyManager alloc] init];
    [instance updateConfig:config];
    return instance;
}

- (void)dealloc {
    [self.reachability stopNotifier];
}

- (void)updateConfig:(NSDictionary *)newConfig {
    @synchronized (self.updateConfigToken) {
        self.config = newConfig;
    }
}

+ (NSDictionary *)loadNewestConfigWithAsync:(BOOL)async handler:(void(^)(NSDictionary *config))handler {
    
    NSDictionary* (^execute)() = ^NSDictionary* {
        NSError *error;
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *getConfigUrl1 = [NSString stringWithFormat:@"https://code.csdn.net/pengguangbo/mbquerystrategy/blob/master/config__ios__%@.json", appVersion];
        
        NSData *configData = [NSData dataWithContentsOfURL:[NSURL URLWithString:getConfigUrl1] options:0 error:&error];
        
        NSDictionary *config = nil;
        if (!error && configData) {
            config = [NSJSONSerialization JSONObjectWithData:configData
                                                     options:0
                                                       error:nil];
        }
        
        if (![config isKindOfClass:[NSDictionary class]]) {
            error = nil;
            configData = nil;
            config = nil;
            NSString *getConfigUrl2 = @"https://code.csdn.net/pengguangbo/mbquerystrategy/blob/master/config.json";
            configData = [NSData dataWithContentsOfURL:[NSURL URLWithString:getConfigUrl2] options:0 error:&error];
            if (configData) {
                config = [NSJSONSerialization JSONObjectWithData:configData
                                                         options:0
                                                           error:nil];
                if (![config isKindOfClass:[NSDictionary class]]) {
                    config = nil;
                }
            }
        }
        
        
        return config;
    };
    
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (handler) handler(execute());
        });
        return nil;
    } else {
        return execute();
    }
}

- (NSMutableDictionary<NSString *,id<MBQueryStrategy>> *)cachedStrategies {
    if (!_cachedStrategies) {
        _cachedStrategies = [NSMutableDictionary<NSString *,id<MBQueryStrategy>> dictionary];
    }
    return _cachedStrategies;
}

+ (id<MBQueryStrategy>)strategyWithImplementCode:(NSString *)implementCode
                                          config:(NSDictionary *)config {
    if (implementCode.length == 0) return nil;
    
    static NSDictionary *strategyDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *kitBundle = [NSBundle bundleForClass:[MBQueryStrategyManager class]];
        strategyDictionary = [NSDictionary dictionaryWithContentsOfURL:[kitBundle URLForResource:@"MBQueryStrategyDictionary" withExtension:@"plist"]];
    });
    
    NSString *strategyClassName = strategyDictionary[implementCode];
    if (!strategyClassName) return nil;
    
    Class providerClasss = NSClassFromString(strategyClassName);
    if (!providerClasss
        || ![providerClasss conformsToProtocol:@protocol(MBQueryStrategy)]) {
        return nil;
    }
    if ([providerClasss respondsToSelector:@selector(strategyWithConfig:)]) {
        return [providerClasss strategyWithConfig:config];
    } else {
        return [[providerClasss alloc] init];
    }
}

- (NSDictionary *)loadConfigAndUpdateIfNeed {
    __block NSDictionary *config = [self.config copy];
    if (config) return config;
    
    config = [[self class] loadNewestConfigWithAsync:NO handler:nil];
    
    [self updateConfig:config];
    if (self.configChangedHandler) self.configChangedHandler(config);
    
    return config;
}

- (void)dispatch_async:(dispatch_block_t)block {
    if (block) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
    }
}

- (id<MBQueryStrategy>)obtainStrategy {
    
    id<MBQueryStrategy> strategy = nil;
    @synchronized (self.obtainStrategyToken) {
        NSDictionary *nowConfig = [self loadConfigAndUpdateIfNeed];
        NSString *version = nowConfig[MBQueryStrategyConfigKey__version];
        NSString *implCode = nowConfig[MBQueryStrategyConfigKey__strategy_impl_code];
        
        NSString *cacheKey = [NSString stringWithFormat:@"%@__%@", version?:@"", implCode?:@""];
        id<MBQueryStrategy> existStrategy = self.cachedStrategies[cacheKey];
        if (existStrategy) {
            strategy = existStrategy;
        } else {
            strategy = [MBQueryStrategyManager strategyWithImplementCode:implCode
                                                                  config:nowConfig];
            if (strategy) {
                self.cachedStrategies[cacheKey] = strategy;
            }
        }
    }
    return strategy;
}

#pragma mark - MBQueryStrategy

- (void)queryMatchList:(MBQueryMatchListRequest *)reqInfo
               handler:(MBQueryMatchListCompleteHandler)handler {
    __weak typeof(self)weakSelf = self;
    [self dispatch_async:^{
        if (!weakSelf) return;
        id<MBQueryStrategy> strategy = [weakSelf obtainStrategy];
        if ([strategy respondsToSelector:@selector(queryMatchList:handler:)]) {
            [strategy queryMatchList:reqInfo handler:handler];
        }
    }];
}

- (void)queryLivingMatchesWithHandler:(MBQueryLivingMatchesCompleteHandler)handler {
    
    __weak typeof(self)weakSelf = self;
    [self dispatch_async:^{
        if (!weakSelf) return;
        id<MBQueryStrategy> strategy = [weakSelf obtainStrategy];
        if ([strategy respondsToSelector:@selector(queryLivingMatchesWithHandler:)]) {
            [strategy queryLivingMatchesWithHandler:handler];
        }
    }];
}

- (void)queryMatchInfo:(NSDictionary<NSString*,
                        NSString*>*(^)(NSString *strategyImplCode))requestInfoBlock
               handler:(MBQueryMatchInfoCompleteHandler)handler {
    
    __weak typeof(self)weakSelf = self;
    [self dispatch_async:^{
        if (!weakSelf) return;
        id<MBQueryStrategy> strategy = [weakSelf obtainStrategy];
        if ([strategy respondsToSelector:@selector(queryMatchInfo:handler:)]) {
            [strategy queryMatchInfo:requestInfoBlock handler:handler];
        }
    }];
}

@end
