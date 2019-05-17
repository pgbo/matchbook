//
//  MBDataController.m
//  matchbook
//
//  Created by guangbool on 2017/6/20.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBDataController.h"
#import <MBKit/MBQueryStrategyManager.h>
#import <MBKit/MBQueryStrategyMacros.h>
#import <MBKit/MMWormhole.h>
#import <MBKit/MBConstants.h>
#import <MBKit/OrderedDictionary.h>
#import <MBKit/NSObject+TDKit.h>
#import <MBKit/NSString+TDKit.h>
#import <MBKit/NSDate+TDKit.h>
#import <MBKit/MBPrefs.h>
#import <objc/runtime.h>
#import <EventKit/EventKit.h>

typedef void(^MBDCRefreshProgramsHandler)(  OrderedDictionary<NSString*/*id*/,MBMatchProgram*> *resultDict,
                                            MBQueryMatchInfoStatus status,
                                            NSString *serviceProvider);

@interface MBDataController ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic) MMWormhole *programWormhole;
// 节目数据更新 token，防止数据更新在多线程下的不安全问题
@property (nonatomic) NSString *updateProgramDatasToken;
@property (nonatomic) MBQueryStrategyManager *queryStrategyManager;

@property (nonatomic) EKEventStore *eventStore;
@property (nonatomic) EKCalendar *eventCalendar;

@end

@implementation MBDataController

- (instancetype)initWithReachability:(Reachability *)reachability {
    if (self = [super init]) {
        self.updateProgramDatasToken = @"updateProgramDatasToken";
        self.reachability = reachability?:[Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
    }
    return self;
}

- (instancetype)init {
    return [self initWithReachability:nil];
}

- (void)dealloc {
    [self.reachability stopNotifier];
}

- (MMWormhole *)programWormhole {
    if (!_programWormhole) {
        _programWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:MBAppGroupName
                                                                optionalDirectory:MBProgramDirectoryName];
    }
    return _programWormhole;
}

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (OrderedDictionary<NSString*,MBMatchProgram*>*)allProgramsOrderedDictionary {
    return [self.programWormhole messageWithIdentifier:MBAllProgramsOrderedDictionaryStoreKey];
}

- (NSArray<NSString *> *)focusedProgramIds {
    return [self.programWormhole messageWithIdentifier:MBFocusedProgramIdsStoreKey];
}

- (NSDictionary<NSString*,NSString*>*)focusedProgramIdAndRemindEventIdDictionary {
    return [self.programWormhole messageWithIdentifier:MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey];
}

- (NSString *)programDatasProvider {
    return [self.programWormhole messageWithIdentifier:MBProgramDatasProviderStoreKey];
}

- (MBQueryStrategyManager *)queryStrategyManager {
    if (!_queryStrategyManager) {
        NSDictionary *lastQueryStrategyConfig = [self.programWormhole messageWithIdentifier:MBQueryStrategyConfigStoreKey];
        _queryStrategyManager = [MBQueryStrategyManager strategyWithConfig:lastQueryStrategyConfig];
        __weak typeof(self)weakSelf = self;
        _queryStrategyManager.configChangedHandler = ^(NSDictionary *newConfig){
            if (!weakSelf) return;
            [weakSelf updateQueryStrategyConfigCache:newConfig];
        };
    }
    return _queryStrategyManager;
}

- (void)updateQueryStrategyConfigCache:(NSDictionary *)newConfig {
    @synchronized (self.updateProgramDatasToken) {
        if (newConfig) {
            // 保存为最新策略配置信息
            [self.programWormhole passMessageObject:newConfig identifier:MBQueryStrategyConfigStoreKey];
        } else {
            // 清除策略配置信息
            [self.programWormhole clearMessageContentsForIdentifier:MBQueryStrategyConfigStoreKey];
        }
    }
}

- (void)updateQueryStrategyManagerConfigIfNeed:(void(^)(NSDictionary *newConfig,
                                                        NSDictionary *oldConfig,
                                                        BOOL networkAvailable))handler {
    __weak typeof(self)weakSelf = self;
    __block BOOL networkAvailable = self.reachability.isReachable;
    [MBQueryStrategyManager loadNewestConfigWithAsync:YES handler:^(NSDictionary *config) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *newConfig = config;
        NSDictionary *lastConfig = [strongSelf.programWormhole messageWithIdentifier:MBQueryStrategyConfigStoreKey];
        
        if (newConfig) networkAvailable = YES;
        
        // update config cache
        [strongSelf updateQueryStrategyConfigCache:newConfig];
        
        // update manager's config
        [strongSelf.queryStrategyManager updateConfig:newConfig];
        
        // 回调
        if (handler) handler(newConfig, lastConfig, networkAvailable);
    }];
}

- (BOOL)shouldRefreshDataWithNewConfig:(NSDictionary *)newConfig
                             oldConfig:(NSDictionary *)oldConfig
              cachedProgramsDictionary:(OrderedDictionary<NSString *, MBMatchProgram *> *)programsOrderedDictionary {
    
    BOOL needRefresh = YES;
    NSString *newConfigVer = newConfig?newConfig[MBQueryStrategyConfigKey__version]:nil;
    NSString *oldConfigVer = oldConfig?oldConfig[MBQueryStrategyConfigKey__version]:nil;
    
    if (newConfig && [newConfigVer isEqualToString:oldConfigVer] && programsOrderedDictionary) {
        NSNumber *cachedSavedTimestamp
        = [self.programWormhole messageWithIdentifier:MBProgramsSavedTimestampStoreKey];
        NSString *intervalObj = newConfig[MBQueryStrategyConfigKey__matches_update_interval_hours];
        NSUInteger updateIntervalHours = [intervalObj isKindOfClass:[NSString class]]?[intervalObj integerValue]:[(NSNumber *)intervalObj integerValue];
        BOOL dataExpires = ({
            BOOL val = NO;
            if (!cachedSavedTimestamp) val = YES;
            else {
                NSInteger hoursSinceNow = ([NSDate date].timeIntervalSince1970 - cachedSavedTimestamp.integerValue)/3600;
                val = (hoursSinceNow >= updateIntervalHours);
            }
            val;
        });
        needRefresh = dataExpires;
    }
    
    return needRefresh;
}

+ (MBMatchProgram *)firstLivingProgramInList:(NSArray<MBMatchProgram *> *)list {
    MBMatchProgram *tar = nil;
    for (MBMatchProgram *prog in list) {
        if (prog.is_living) {
            tar = prog;
            break;
        }
    }
    return tar;
}

+ (NSArray<MBMatchProgram *> *)getReturnProgramsForListType:(MBDataControllerMatchListType)listType
                                       allProgramDictionary:(OrderedDictionary<NSString*,
                                                             MBMatchProgram*>*)allProgramDictionary
                                          focusedProgramIds:(NSArray<NSString *>*)focusedProgramIds
                                             referProgramId:(NSString *)referProgramId
                                                   pageSize:(NSInteger)pageSize {
    
    void(^listAddFromIds)(NSMutableArray<MBMatchProgram*> *,
                          NSArray<NSString*> *,
                          NSArray<NSString *> *,
                          OrderedDictionary<NSString*,MBMatchProgram*> *)
        = ^(NSMutableArray<MBMatchProgram*> *list,
            NSArray<NSString*> *addingIds,
            NSArray<NSString *> *focusedIds,
            OrderedDictionary<NSString *, MBMatchProgram *> *allProgramDict){
            if (!list) return;
            for (NSString *_id in addingIds) {
                MBMatchProgram *prog = [allProgramDict[_id] copy];
                prog.focused = [focusedIds containsObject:_id];
                if (prog == nil) {
                    NSLog(@"HOW COULD 'prog == nil?'");
                }
                if (![list containsObject:prog]) {
                    [list addObject:prog];
                }
            }
        };
    
    NSArray<NSString *> *allProgramIds = allProgramDictionary.allKeys?:@[];
    NSMutableArray<MBMatchProgram *> *optList = [NSMutableArray<MBMatchProgram *> array];
    if (listType & MBDataControllerMatchList_All) {
        listAddFromIds(optList, allProgramIds, focusedProgramIds, allProgramDictionary);
    } else {
        
        // 「重要」
        NSMutableArray<NSString *> *importantProgramIds = [NSMutableArray array];
        // 「足球」
        NSMutableArray<NSString *> *footballProgramIds = [NSMutableArray array];
        // 「篮球」
        NSMutableArray<NSString *> *basketballProgramIds = [NSMutableArray array];
        // 「正在进行中」
        NSMutableArray<NSString *> *livingProgramIds = [NSMutableArray array];
        
        for (NSString *p_id in allProgramIds) {
            MBMatchProgram *program = allProgramDictionary[p_id];
            if (program.is_important > 0) {
                [importantProgramIds addObject:p_id];
            }
            if (program.is_football > 0) {
                [footballProgramIds addObject:p_id];
            }
            if (program.is_basketball > 0) {
                [basketballProgramIds addObject:p_id];
            }
            if (program.is_living > 0) {
                [livingProgramIds addObject:p_id];
            }
        }
        
        if (listType & MBDataControllerMatchList_Important) {
            listAddFromIds(optList, importantProgramIds, focusedProgramIds, allProgramDictionary);
        }
        if (listType & MBDataControllerMatchList_Football) {
            listAddFromIds(optList, footballProgramIds, focusedProgramIds, allProgramDictionary);
        }
        if (listType & MBDataControllerMatchList_Basketball) {
            listAddFromIds(optList, basketballProgramIds, focusedProgramIds, allProgramDictionary);
        }
        if (listType & MBDataControllerMatchList_Focus) {
            listAddFromIds(optList, focusedProgramIds, focusedProgramIds, allProgramDictionary);
        }
        if (listType & MBDataControllerMatchList_Living) {
            listAddFromIds(optList, livingProgramIds, focusedProgramIds, allProgramDictionary);
        }
    }
    
    // 排序
    [optList sortUsingComparator:^NSComparisonResult(MBMatchProgram *obj1,
                                                     MBMatchProgram *obj2) {
        NSInteger obj1_idx = [allProgramIds indexOfObject:obj1.program_id];
        NSInteger obj2_idx = [allProgramIds indexOfObject:obj2.program_id];
        if (obj1_idx != NSNotFound && obj2_idx != NSNotFound) {
            if (obj1_idx < obj2_idx) return NSOrderedAscending;
            if (obj1_idx == obj2_idx) return NSOrderedSame;
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    NSArray<MBMatchProgram *> *returnResults
        = [MBDataController getReturnProgramsWithOriginalList:optList
                                               referProgramId:referProgramId
                                                     pageSize:pageSize];
    return returnResults;
}

+ (NSArray<MBMatchProgram *> *)getReturnProgramsWithOriginalList:(NSArray<MBMatchProgram *> *)originalList
                                                  referProgramId:(NSString *)referProgramId
                                                        pageSize:(NSInteger)pageSize {
    if (!originalList) return nil;
    NSUInteger originalCount = originalList.count;
    
    NSUInteger returnSize = MIN(pageSize, originalCount);
    NSUInteger returnOffset = 0;
    if (referProgramId) {
        NSArray<NSString *> *listIds = [originalList valueForKeyPath:NSStringFromSelector(@selector(program_id))];
        NSInteger firstReferIdx = [listIds indexOfObject:referProgramId];
        if (firstReferIdx != NSNotFound) {
            if (pageSize < 0) {
                returnOffset = firstReferIdx + pageSize;
                returnSize = (firstReferIdx - returnOffset);
            } else if (pageSize > 0) {
                returnOffset = firstReferIdx;
                returnSize = MIN((originalCount - (firstReferIdx + 1)), pageSize);
            }
        }
    }
    
    NSMutableArray<MBMatchProgram *> *returnResults = [NSMutableArray<MBMatchProgram *> array];
    for (NSUInteger i = returnOffset; i < (returnOffset + returnSize); i++) {
        if (i >= originalCount) break;
        
        MBMatchProgram *prog = originalList[i];
        [returnResults addObject:prog];
    }
    
    return returnResults;
}

- (void)refreshProgramList:(MBDCRefreshProgramListRequest *)request
                   handler:(MBQueryMatchListCompleteHandler)handler {
    
    NSAssert(request != nil, @"request can't be nil");
    NSAssert(request.pageSize != 0, @"pageSize can't equal to 0");

    MBQueryMatchListCompleteHandler safeHandler = ^(NSArray<MBMatchProgram *>   *results,
                                                    MBQueryMatchInfoStatus      status,
                                                    NSString                    *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(results, status, serviceProvider);
        });
    };
    
    
    
    __weak typeof(self)weakSelf = self;
    [self updateQueryStrategyManagerConfigIfNeed:^(NSDictionary *newConfig, NSDictionary *old, BOOL networkAvailable) {
        if (!weakSelf) return;
        
        if (!networkAvailable) {
            safeHandler(nil, MBQueryMatchInfoNoNetwork, nil);
            return;
        }
        
        [weakSelf.queryStrategyManager queryMatchList:({
            MBQueryMatchListRequest *info = [[MBQueryMatchListRequest alloc] init];
            info.shouldQueryScoreInfo = YES;
            info;
        }) handler:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!weakSelf) return;
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                if (status != MBQueryMatchInfoSuccess) {
                    safeHandler(nil, status, serviceProvider);
                    return;
                }

                // 「正在进行中」
                NSMutableArray<NSString *> *livingProgramIds = [NSMutableArray array];
                // 「全部比赛列表」
                MutableOrderedDictionary *programsOrderedDict = [MutableOrderedDictionary dictionary];
                for (MBMatchProgram *program in results) {
                    MBMatchProgram *copyProg = [program copy];
                    NSString *p_id = copyProg.program_id;
                    // Configure id if id is empty.
                    if (p_id.length == 0) p_id = [NSString stringWithUUID];
                    // Update 'program_id' if need
                    copyProg.program_id = p_id;
                    
                    // Add into 'programsOrderedDict'
                    programsOrderedDict[p_id] = copyProg;
                    
                    // Add into living if need
                    if (program.is_living > 0) {
                        [livingProgramIds addObject:p_id];
                    }
                }
                
                NSString *newServiceProvider = serviceProvider?:@"";
                NSArray<NSString *> *newFocusedProgramIds = nil;
                
                @synchronized (strongSelf.updateProgramDatasToken) {
                    // 获取 focusedProgramIds
                    newFocusedProgramIds = ({
                        NSArray<NSString *> *focusedIds = [strongSelf focusedProgramIds];
                        NSArray<NSString *> *allProgramIds = programsOrderedDict.allKeys;
                        focusedIds = [focusedIds filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
                            return [allProgramIds containsObject:evaluatedObject];
                        }]];
                        if (!focusedIds) focusedIds = @[];
                        focusedIds;
                    });
                    
                    // 更新「数据提供商」
                    [strongSelf.programWormhole passMessageObject:newServiceProvider identifier:MBProgramDatasProviderStoreKey];
                    
                    // 更新「全部比赛列表」
                    [strongSelf.programWormhole passMessageObject:programsOrderedDict identifier:MBAllProgramsOrderedDictionaryStoreKey];
                    
                    // 更新「关注」
                    [strongSelf.programWormhole passMessageObject:newFocusedProgramIds identifier:MBFocusedProgramIdsStoreKey];
                    
                    // 更新「最新数据的保存时间」
                    [strongSelf.programWormhole passMessageObject:@([NSDate date].timeIntervalSince1970)
                                                       identifier:MBProgramsSavedTimestampStoreKey];
                }
                
                // 获取正确的列表
                NSString *referProgramId = request.listBeginFromLiving?livingProgramIds.firstObject:nil;
                NSArray<MBMatchProgram *> *returnResults
                     = [MBDataController getReturnProgramsForListType:request.returnListType
                                                 allProgramDictionary:programsOrderedDict
                                                    focusedProgramIds:newFocusedProgramIds
                                                       referProgramId:referProgramId
                                                             pageSize:request.pageSize];
                
                // 回调
                safeHandler(returnResults, status, newServiceProvider);
            });
        }];
    }];
}

- (void)loadProgramList:(MBDCLoadProgramListRequest *)request
                handler:(MBDCLoadProgramListHandler)handler {

    MBDCLoadProgramListHandler safeHandler = ^(NSString                    *resultsReferProgramId,
                                               NSArray<MBMatchProgram *>   *results,
                                               MBQueryMatchInfoStatus      status,
                                               NSString                    *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
           if (handler) handler(resultsReferProgramId, results, status, serviceProvider);
        });
    };
    
    // 加载规则
    // 判断当前数据是否有效
    // 1. 前后两次的配置信息的版本号一样
    // 2. 存在上一次保存的比赛数据
    // 3. 上一次保存的比赛数据未过期
    // 如果以上条件不满足，则刷新数据
    __weak typeof(self)weakSelf = self;
    [self updateQueryStrategyManagerConfigIfNeed:^(NSDictionary *newConfig, NSDictionary *oldConfig, BOOL networkAvailable) {
        
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        OrderedDictionary<NSString *, MBMatchProgram *> *cachedProgramsOrderedDict
            = [weakSelf allProgramsOrderedDictionary];
        
        BOOL needRefresh = [weakSelf shouldRefreshDataWithNewConfig:newConfig
                                                          oldConfig:oldConfig
                                           cachedProgramsDictionary:cachedProgramsOrderedDict];
        
        
        if (networkAvailable && needRefresh) {
            __weak typeof(self)weakSelf = strongSelf;
            [strongSelf refreshProgramList:({
                MBDCRefreshProgramListRequest *info = [[MBDCRefreshProgramListRequest alloc] init];
                info.returnListType = request.type;
                info.listBeginFromLiving = request.listBeginFromLivingWhenReferIdUnavailable;
                info.pageSize = request.pageSize>0?request.pageSize:50;
                info;
            }) handler:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
                if (!weakSelf) return;
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (status == MBQueryMatchInfoSuccess) {
                    // Success
                    safeHandler(nil, results, status, serviceProvider);
                    return;
                }
                
                // Else Failed or Error
                OrderedDictionary *programsOrderedDict = [strongSelf allProgramsOrderedDictionary];
                NSString *referProgramId = request.referProgramId;
                if (!referProgramId && request.listBeginFromLivingWhenReferIdUnavailable) {
                    referProgramId = [MBDataController firstLivingProgramInList:programsOrderedDict.allValues].program_id;
                }
                
                NSArray<MBMatchProgram *> *returnResults =
                [MBDataController getReturnProgramsForListType:request.type
                                          allProgramDictionary:programsOrderedDict
                                             focusedProgramIds:[strongSelf focusedProgramIds]
                                                referProgramId:referProgramId
                                                      pageSize:request.pageSize];
                
                NSString *oldService = [strongSelf programDatasProvider];
                // 回调
                safeHandler(referProgramId, returnResults, status, oldService);
                
            }];
        } else {
            // No need refresh

            NSString *referProgramId = request.referProgramId;
            if (!referProgramId && request.listBeginFromLivingWhenReferIdUnavailable) {
                referProgramId = [MBDataController firstLivingProgramInList:cachedProgramsOrderedDict.allValues].program_id;
            }
            
            NSArray<MBMatchProgram *> *returnResults =
                [MBDataController getReturnProgramsForListType:request.type
                                          allProgramDictionary:cachedProgramsOrderedDict
                                             focusedProgramIds:[strongSelf focusedProgramIds]
                                                referProgramId:referProgramId
                                                      pageSize:request.pageSize];
            
            NSString *oldService = [strongSelf programDatasProvider];
            // 回调
            safeHandler(referProgramId, returnResults, MBQueryMatchInfoSuccess, oldService);
        }
    }];
}

- (void)refreshAllLivingProgramList:(MBQueryMatchListCompleteHandler)handler {
    
    MBQueryMatchListCompleteHandler safeHandler = ^(NSArray<MBMatchProgram *>   *results,
                                                    MBQueryMatchInfoStatus      status,
                                                    NSString                    *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(results, status, serviceProvider);
        });
    };

    __weak typeof(self)weakSelf = self;
    [self.queryStrategyManager queryLivingMatchesWithHandler:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        if (status != MBQueryMatchInfoSuccess) {
            safeHandler(nil, status, serviceProvider);
            return;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        // 根据日期升序排序
        NSArray<MBMatchProgram*> *sortedResults = [results sortedArrayUsingComparator:^NSComparisonResult(MBMatchProgram *o1, MBMatchProgram *o2) {
            if (o1.program_date < o2.program_date) return NSOrderedAscending;
            if (o1.program_date > o2.program_date) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        MutableOrderedDictionary<NSString*,MBMatchProgram*> *nowLivingDictionary = [MutableOrderedDictionary dictionary];
        for (MBMatchProgram *prog in sortedResults) {
            if (prog.is_living <= 0 || prog.program_id.length == 0) continue;
            nowLivingDictionary[prog.program_id] = prog;
        }
        NSArray<NSString *> *nowLivingIds = nowLivingDictionary.allKeys;
        NSArray<MBMatchProgram *> *nowLivingPrograms = nowLivingDictionary.allValues;
        
        @synchronized (strongSelf.updateProgramDatasToken) {
            
            OrderedDictionary<NSString*,MBMatchProgram*> *allProgramDict = [strongSelf allProgramsOrderedDictionary];
            
            // update living state
            
            [allProgramDict.allValues enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {
                // update all living's program to `unkown` state
                obj.is_living = -1;
                
                // tag the newest living program
                if ([nowLivingIds containsObject:obj.program_id]) {
                    [obj fillPropertiesWithAnother:nowLivingDictionary[obj.program_id] ignoreUnkownValueFields:YES];
                    obj.is_living = 1;
                }
            }];
            
            // 更新「全部比赛列表」
            [strongSelf.programWormhole passMessageObject:allProgramDict
                                               identifier:MBAllProgramsOrderedDictionaryStoreKey];
        }
        
        safeHandler(nowLivingPrograms, status, serviceProvider);
    }];
}

- (void)requestEventAccessIfNeed:(void(^ _Nonnull)(EKAuthorizationStatus status))completion {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusAuthorized: {
            completion(status);
            break;
        }
        case EKAuthorizationStatusNotDetermined: {
            [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                            completion:^(BOOL granted, NSError *error) {
                                                completion(granted?EKAuthorizationStatusAuthorized:EKAuthorizationStatusDenied);
                                            }];
            break;
        }
    }
}

- (BOOL)createEventCalendarIfNeed {
    if (!_eventCalendar) {
        
        NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
        
        NSString *calendarTitle = @"Matchbook";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count] > 0) {
            // Exist
            _eventCalendar = [filtered firstObject];
            return YES;
        } else {
            // Not exist, create it!
            _eventCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
            _eventCalendar.title = calendarTitle;
            _eventCalendar.source = self.eventStore.defaultCalendarForNewEvents.source;
            
            // 4
            NSError *calendarErr = nil;
            BOOL createResult = [self.eventStore saveCalendar:_eventCalendar commit:YES error:&calendarErr];
            return createResult;
        }
    }
    return YES;
}

- (void)addRemindForProgramWithId:(NSString *)programId handler:(void(^)(BOOL success))handler {
    
    void(^safeHandler)(BOOL) = ^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(success);
        });
    };
    
    NSAssert(programId != nil, @"programId can't be nil");
    
    MBMatchProgram *program = [self allProgramsOrderedDictionary][programId];
    if (!program) {
        safeHandler(NO);
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self requestEventAccessIfNeed:^(EKAuthorizationStatus status) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!weakSelf) return;
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (status != EKAuthorizationStatusAuthorized) {
                safeHandler(NO);
                return;
            }
            
            if (![strongSelf createEventCalendarIfNeed]) {
                safeHandler(NO);
                return;
            }
            
            NSString *title = ({
                NSString *info = nil;
                if (program.participants.count>0) {
                    info = [program.participants componentsJoinedByString:@" VS "];
                } else if (program.program_name.length > 0) {
                    info = program.program_name;
                } else {
                    info = @"节目提醒";
                }
                info;
            });
            EKEvent *evt = [EKEvent eventWithEventStore:strongSelf.eventStore];
            evt.title = title;
            evt.notes = program.participants.count>0?[program.participants componentsJoinedByString:@"VS"]:nil;
            evt.startDate = [NSDate dateWithTimeIntervalSince1970:program.program_date];
            evt.endDate = [evt.startDate dateByAddingTimeInterval:30];
            evt.calendar = strongSelf.eventCalendar;
            MBProgramRemindTime remindTime =  [MBPrefs shared].programRemindTime;
            NSInteger alarmOffset = (-1)*(remindTime>0?remindTime:0);
            [evt addAlarm:[EKAlarm alarmWithRelativeOffset:alarmOffset]];
            evt.recurrenceRules = nil;
            
            NSError *error = nil;
            [strongSelf.eventStore saveEvent:evt span:EKSpanThisEvent error:&error];
            
            BOOL success = (error == nil);
            if (success) {
                @synchronized (strongSelf.updateProgramDatasToken) {
                    // 更新「关注」
                    NSArray<NSString *> *oldFocusIds = [strongSelf focusedProgramIds];
                    if (![oldFocusIds containsObject:programId]) {
                        NSMutableArray<NSString *> *newFocusIds = [NSMutableArray arrayWithArray:oldFocusIds?:@[]];
                        [newFocusIds addObject:programId];
                        [strongSelf.programWormhole passMessageObject:newFocusIds identifier:MBFocusedProgramIdsStoreKey];
                    }
                    
                    // 更新 「eventIdentifier 和 program 的联系」
                    NSDictionary<NSString*,NSString*> *focusedRemindIds = [strongSelf focusedProgramIdAndRemindEventIdDictionary];
                    NSMutableDictionary *newFocusedRemindIds = [NSMutableDictionary dictionaryWithDictionary:focusedRemindIds?:@{}];
                    newFocusedRemindIds[programId] = evt.eventIdentifier;
                    [strongSelf.programWormhole passMessageObject:newFocusedRemindIds identifier:MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey];
                }
            }
            
            safeHandler(success);
        });
    }];
}

- (void)removeRemindForProgramWithId:(NSString *)programId handler:(void(^)(BOOL success))handler {
    
    void(^safeHandler)(BOOL) = ^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(success);
        });
    };
    
    NSAssert(programId != nil, @"programId can't be nil");
    
    MBMatchProgram *program = [self allProgramsOrderedDictionary][programId];
    if (!program) {
        safeHandler(NO);
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self requestEventAccessIfNeed:^(EKAuthorizationStatus status) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!weakSelf) return;
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (status != EKAuthorizationStatusAuthorized) {
                safeHandler(NO);
                return;
            }
            
            if (![strongSelf createEventCalendarIfNeed]) {
                safeHandler(NO);
                return;
            }
            
            // 通过 eventIdentifier 和 program id 的联系获得 eventIdentifier
            // 再通过 eventIdentifier 获取 Event，然后删除它
            NSString *existRemindId = [strongSelf focusedProgramIdAndRemindEventIdDictionary][programId];
            if (!existRemindId) {
                safeHandler(YES);
                return;
            }
            EKEvent *evt = [strongSelf.eventStore eventWithIdentifier:existRemindId];
            if (evt) {
                NSError *error = nil;
                [strongSelf.eventStore removeEvent:evt span:EKSpanThisEvent error:&error];
                if (error) {
                    safeHandler(NO);
                    return;
                }
            }
            
            @synchronized (strongSelf.updateProgramDatasToken) {
                // 更新「关注」
                NSArray<NSString *> *oldFocusIds = [strongSelf focusedProgramIds];
                if ([oldFocusIds containsObject:programId]) {
                    NSMutableArray<NSString *> *newFocusIds = [NSMutableArray arrayWithArray:oldFocusIds?:@[]];
                    [newFocusIds removeObject:programId];
                    [strongSelf.programWormhole passMessageObject:newFocusIds identifier:MBFocusedProgramIdsStoreKey];
                }
                
                // 更新 「eventIdentifier 和 program 的联系」
                NSDictionary<NSString*,NSString*> *focusedRemindIds = [strongSelf focusedProgramIdAndRemindEventIdDictionary];
                NSMutableDictionary *newFocusedRemindIds = [NSMutableDictionary dictionaryWithDictionary:focusedRemindIds?:@{}];
                [newFocusedRemindIds removeObjectForKey:programId];
                [strongSelf.programWormhole passMessageObject:newFocusedRemindIds identifier:MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey];
            }
            
            safeHandler(YES);
        });
    }];
}

- (void)refreshProgramsWithHandler:(MBDCRefreshProgramsHandler)handler {
    
    MBDCRefreshProgramsHandler safeHandler = ^(OrderedDictionary<NSString*/*id*/,MBMatchProgram*> *resultDict,
                                               MBQueryMatchInfoStatus status,
                                               NSString *serviceProvider){
        if (handler) handler(resultDict, status, serviceProvider);
    };
    
    __weak typeof(self)weakSelf = self;
    [self updateQueryStrategyManagerConfigIfNeed:^(NSDictionary *newConfig, NSDictionary *old, BOOL networkAvailable) {
        if (!weakSelf) return;
        
        if (!networkAvailable) {
            safeHandler(nil, MBQueryMatchInfoNoNetwork, nil);
            return;
        }
        
        [weakSelf.queryStrategyManager queryMatchList:({
            MBQueryMatchListRequest *info = [[MBQueryMatchListRequest alloc] init];
            info.shouldQueryScoreInfo = YES;
            info;
        }) handler:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!weakSelf) return;
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                if (status != MBQueryMatchInfoSuccess) {
                    safeHandler(nil, status, serviceProvider);
                    return;
                }
                
                // 「正在进行中」
                NSMutableArray<NSString *> *livingProgramIds = [NSMutableArray array];
                // 「全部比赛列表」
                MutableOrderedDictionary *programsOrderedDict = [MutableOrderedDictionary dictionary];
                for (MBMatchProgram *program in results) {
                    MBMatchProgram *copyProg = [program copy];
                    NSString *p_id = copyProg.program_id;
                    // Configure id if id is empty.
                    if (p_id.length == 0) p_id = [NSString stringWithUUID];
                    // Update 'program_id' if need
                    copyProg.program_id = p_id;
                    
                    // Add into 'programsOrderedDict'
                    programsOrderedDict[p_id] = copyProg;
                    
                    // Add into living if need
                    if (program.is_living > 0) {
                        [livingProgramIds addObject:p_id];
                    }
                }
                
                NSString *newServiceProvider = serviceProvider?:@"";
                
                @synchronized (strongSelf.updateProgramDatasToken) {
                    // 获取 focusedProgramIds
                    NSArray<NSString *> *newFocusedProgramIds = ({
                        NSArray<NSString *> *focusedIds = [strongSelf focusedProgramIds];
                        NSArray<NSString *> *allProgramIds = programsOrderedDict.allKeys;
                        focusedIds = [focusedIds filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
                            return [allProgramIds containsObject:evaluatedObject];
                        }]];
                        if (!focusedIds) focusedIds = @[];
                        focusedIds;
                    });
                    
                    NSDictionary<NSString*,NSString*> *oldRemindDict = [strongSelf focusedProgramIdAndRemindEventIdDictionary];
                    NSMutableDictionary *newRemindProgramIds = [NSMutableDictionary dictionary];
                    NSMutableSet *needRemoveRemindIds = [NSMutableSet set];
                    [oldRemindDict enumerateKeysAndObjectsUsingBlock:^(NSString *progId, NSString *remindId, BOOL *stop) {
                        if ([newFocusedProgramIds containsObject:progId]) {
                            newRemindProgramIds[progId] = remindId;
                        } else {
                            [needRemoveRemindIds addObject:remindId];
                        }
                    }];
                    
                    // 更新「数据提供商」
                    [strongSelf.programWormhole passMessageObject:newServiceProvider identifier:MBProgramDatasProviderStoreKey];
                    
                    // 更新「全部比赛列表」
                    [strongSelf.programWormhole passMessageObject:programsOrderedDict identifier:MBAllProgramsOrderedDictionaryStoreKey];
                    
                    // 更新「关注」
                    [strongSelf.programWormhole passMessageObject:newFocusedProgramIds identifier:MBFocusedProgramIdsStoreKey];
                    
                    // 更新「关注的比赛和提醒的关联」
                    [strongSelf.programWormhole passMessageObject:newRemindProgramIds identifier:MBFocusedProgramIdAndRemindEventIdDictionaryStoreKey];
                    
                    // 更新「最新数据的保存时间」
                    [strongSelf.programWormhole passMessageObject:@([NSDate date].timeIntervalSince1970)
                                                       identifier:MBProgramsSavedTimestampStoreKey];
                    
                    // 删除之前的一些比赛提醒信息
                    for (NSString *remindId in needRemoveRemindIds) {
                        EKEvent *evt = [strongSelf.eventStore eventWithIdentifier:remindId];
                        if (evt) {
                            NSError *error = nil;
                            [strongSelf.eventStore removeEvent:evt span:EKSpanThisEvent error:&error];
                        }
                    }
                }
                
                // 回调
                safeHandler(programsOrderedDict, status, newServiceProvider);
            });
        }];
    }];
}

+ (OrderedDictionary<NSDate*,NSArray<MBMatchProgram*>*>*)getDayProgramSetsForListType:(MBDataControllerMatchListType)listType allProgramDictionary:(OrderedDictionary<NSString*,MBMatchProgram*>*)allProgramDictionary focusedProgramIds:(NSArray<NSString *>*)focusedProgramIds startFromDay:(NSDate *)startFromDay minimumNum:(NSUInteger)minimumNum days:(NSUInteger)days forwardQuery:(BOOL)forwardQuery {
    
    if (!allProgramDictionary) return nil;
    
    __block MutableOrderedDictionary<NSString*,MBMatchProgram*> *targetProgramDict = [MutableOrderedDictionary dictionary];
    if (listType & MBDataControllerMatchList_All) {
        targetProgramDict = [allProgramDictionary copy];
    } else {
        
        [allProgramDictionary.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            MBMatchProgram *prog = allProgramDictionary[obj];
            if ((prog.is_important > 0 && (listType & MBDataControllerMatchList_Important))
                || (prog.is_football > 0 && (listType & MBDataControllerMatchList_Football))
                || (prog.is_basketball > 0 && (listType & MBDataControllerMatchList_Basketball))
                || (prog.is_living > 0 && (listType & MBDataControllerMatchList_Living))) {
                if (![targetProgramDict.allKeys containsObject:obj]) {
                    targetProgramDict[obj] = allProgramDictionary[obj];
                }
            } else if ((listType & MBDataControllerMatchList_Focus)
                       && [focusedProgramIds containsObject:obj]
                       && ![targetProgramDict.allKeys containsObject:obj]) {
                targetProgramDict[obj] = allProgramDictionary[obj];
            }
        }];
    }
    
    __block MutableOrderedDictionary<NSDate *, NSMutableArray<MBMatchProgram*>*> *dayProgramSets = [MutableOrderedDictionary<NSDate *, NSMutableArray<MBMatchProgram*>*> dictionary];
    [targetProgramDict.allValues enumerateObjectsUsingBlock:^(MBMatchProgram *obj, NSUInteger idx, BOOL *stop) {
        NSDate *progDate = [NSDate dateWithTimeIntervalSince1970:obj.program_date];
        NSDate *dayDate = [progDate sameDayWithHour:0 minute:0 second:0];
        
        NSMutableArray<MBMatchProgram*> *list = dayProgramSets[dayDate];
        if (!list) {
            list = [NSMutableArray<MBMatchProgram*> array];
            dayProgramSets[dayDate] = list;
        }
        
        MBMatchProgram *progCopy = [obj copy];
        // Configure `focused`
        progCopy.focused = [focusedProgramIds containsObject:progCopy.program_id];
        
        [list addObject:progCopy];
    }];
    
    NSDate *startDay = startFromDay?[startFromDay sameDayWithHour:0 minute:0 second:0]:nil;
    NSUInteger offset = 0;
    NSUInteger dayLength = 0;
    if (startDay) {
        NSUInteger startDayIdx = [dayProgramSets.allKeys indexOfObject:startDay];
        if (startDayIdx != NSNotFound) {
            if (forwardQuery) {
                offset = startDayIdx;
                dayLength = MIN(days, dayProgramSets.count - startDayIdx);
            } else {
                offset = startDayIdx - days + 1;
                dayLength = startDayIdx - offset + 1;
            }
        } else {
            NSDate *setsFirstDay = dayProgramSets.allKeys.firstObject;
            if (setsFirstDay) {
                NSInteger daysGap = [startDay daysNumSinceAnotherDay:setsFirstDay];
                if (forwardQuery && daysGap < 0) {
                    offset = 0;
                    dayLength = MIN(days + daysGap, dayProgramSets.count);
                }
            }
        }
    } else if (forwardQuery){
        dayLength = MIN(days, dayProgramSets.count);
    }
    
    MutableOrderedDictionary<NSDate *, NSArray<MBMatchProgram*>*> *resultSets = [MutableOrderedDictionary<NSDate *, NSArray<MBMatchProgram*>*> dictionary];
    NSArray<NSDate *> *allDayKeys = dayProgramSets.allKeys;
    NSUInteger addingNum = 0;
    for (NSUInteger i = offset; i < (offset + dayLength); i++) {
        NSDate *dayKey = allDayKeys[i];
        NSArray<MBMatchProgram *> *dayPrograms = dayProgramSets[dayKey];
        resultSets[dayKey] = dayPrograms;
        addingNum += dayPrograms.count;
    }
    
    if (minimumNum > 0 && addingNum < minimumNum) {
        NSUInteger restOffset = offset + dayLength;
        if (restOffset > offset && allDayKeys.count > restOffset) {
            NSUInteger i = restOffset;
            while (addingNum < minimumNum && allDayKeys.count > i) {
                NSDate *dayKey = allDayKeys[i];
                NSArray<MBMatchProgram *> *dayPrograms = dayProgramSets[dayKey];
                resultSets[dayKey] = dayPrograms;
                addingNum += dayPrograms.count;
                i++;
            }
        }
    }
    
    return resultSets;
}

/**
 刷新节目，并返回对应请求的结果
 
 @param request 请求信息
 @param handler 结果处理
 */
- (void)refreshProgramsInDay:(MBDCRefreshProgramsInDayRequest *)request
                     handler:(MBDCRefreshProgramsInDayHandler)handler {
    
    NSAssert(request != nil, @"request can't be nil");
    
    MBDCRefreshProgramsInDayHandler safeHandler = ^(MBDCRefreshProgramsInDayReturn *returnn,
                                                    MBQueryMatchInfoStatus status,
                                                    NSString *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(returnn, status, serviceProvider);
        });
    };
    
    
    __weak typeof(self)weakSelf = self;
    [self refreshProgramsWithHandler:^(OrderedDictionary<NSString *,MBMatchProgram *> *resultDict, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (status != MBQueryMatchInfoSuccess) {
            safeHandler(nil, status, serviceProvider);
            return;
        }
        
        MBDCRefreshProgramsInDayReturn *returnn = [MBDCRefreshProgramsInDayReturn new];
        returnn.dayProgramSets = [strongSelf.class getDayProgramSetsForListType:request.returnListType allProgramDictionary:resultDict focusedProgramIds:[strongSelf focusedProgramIds] startFromDay:request.startFromDay minimumNum:request.minimumNum days:request.days forwardQuery:YES];
        
        // 回调
        safeHandler(returnn, status, serviceProvider);
    }];
}

/**
 按天查询节目
 
 @param request 请求信息
 @param handler 结果处理
 */
- (void)loadProgramsInDay:(MBDCLoadProgramsInDayRequest *)request
                  handler:(MBDCLoadProgramsInDayHandler)handler {

    MBDCLoadProgramsInDayHandler safeHandler = ^(MBDCLoadProgramsInDayReturn *returnn,
                                                 MBQueryMatchInfoStatus      status,
                                                 NSString                    *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) handler(returnn, status, serviceProvider);
        });
    };
    
    // 加载规则
    // 判断当前数据是否有效
    // 1. 前后两次的配置信息的版本号一样
    // 2. 存在上一次保存的比赛数据
    // 3. 上一次保存的比赛数据未过期
    // 如果以上条件不满足，则刷新数据
    __weak typeof(self)weakSelf = self;
    [self updateQueryStrategyManagerConfigIfNeed:^(NSDictionary *newConfig, NSDictionary *oldConfig, BOOL networkAvailable) {
        
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        OrderedDictionary<NSString *, MBMatchProgram *> *cachedProgramsOrderedDict
        = [weakSelf allProgramsOrderedDictionary];
        
        BOOL needRefresh = [weakSelf shouldRefreshDataWithNewConfig:newConfig
                                                          oldConfig:oldConfig
                                           cachedProgramsDictionary:cachedProgramsOrderedDict];
        
        
        if (networkAvailable && needRefresh) {
            __weak typeof(self)weakSelf = strongSelf;
            [strongSelf refreshProgramsInDay:request.refreshInfoWhenNeedRefresh handler:^(MBDCRefreshProgramsInDayReturn *returnn, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
                if (!weakSelf) return;
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (status == MBQueryMatchInfoSuccess) {
                    // Success
                    MBDCLoadProgramsInDayReturn *loadReturn = [MBDCLoadProgramsInDayReturn new];
                    loadReturn.needRefresh = YES;
                    loadReturn.dayProgramSets = returnn.dayProgramSets;
                    safeHandler(loadReturn, status, serviceProvider);
                    return;
                }
                
                // Else Failed or Error
                [strongSelf loadLocalProgramsInDay:request handler:safeHandler];
            }];
            
        } else {
            // No need refresh
            [strongSelf loadLocalProgramsInDay:request handler:safeHandler];
        }
    }];
}

- (void)loadLocalProgramsInDay:(MBDCLoadProgramsInDayRequest *)request
                       handler:(MBDCLoadProgramsInDayHandler)handler {
    
    MBDCLoadProgramsInDayHandler safeHandler = ^(MBDCLoadProgramsInDayReturn *returnn,
                                                 MBQueryMatchInfoStatus      status,
                                                 NSString                    *serviceProvider){
        if (handler) handler(returnn, status, serviceProvider);
    };
    __weak typeof(self)weakSelf = self;
    
    void(^loadLocalProgramsCallback)() = ^{
        if (!weakSelf) return;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        OrderedDictionary *programsOrderedDict = [strongSelf allProgramsOrderedDictionary];
        
        MBDCLoadProgramsInDayReturn *loadReturn = [MBDCLoadProgramsInDayReturn new];
        loadReturn.needRefresh = NO;
        loadReturn.dayProgramSets = [strongSelf.class getDayProgramSetsForListType:request.listType allProgramDictionary:programsOrderedDict focusedProgramIds:[strongSelf focusedProgramIds] startFromDay:request.startFromDay minimumNum:request.minimumNum days:request.days forwardQuery:request.forwardQuery];
        
        
        NSString *oldService = [strongSelf programDatasProvider];
        // 回调
        safeHandler(loadReturn, MBQueryMatchInfoSuccess, oldService);
    };
    
    if (request.loadNewestLivingState) {
        [self refreshAllLivingProgramList:^(NSArray<MBMatchProgram *> *results, MBQueryMatchInfoStatus status, NSString *serviceProvider) {
            loadLocalProgramsCallback();
        }];
    } else {
        loadLocalProgramsCallback();
    }
}

@end


@implementation MBDCRefreshProgramListRequest
@end

@implementation MBDCLoadProgramListRequest
@end

@implementation MBMatchProgram (MBDataController)
@dynamic focused;

- (void)setFocused:(BOOL)focused {
    [self setAssociateValue:@(focused) withKey:@"focused"];
}

- (BOOL)focused {
    NSNumber *val = [self getAssociatedValueForKey:@"focused"];
    return [val boolValue];
}

@end


@implementation MBDCRefreshProgramsInDayRequest
@end

@implementation MBDCRefreshProgramsInDayReturn
@end

@implementation MBDCLoadProgramsInDayRequest
@end

@implementation MBDCLoadProgramsInDayReturn
@end
