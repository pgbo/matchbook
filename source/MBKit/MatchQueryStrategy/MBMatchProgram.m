//
//  MBMatchProgram.m
//  matchbook
//
//  Created by guangbool on 2017/6/15.
//  Copyright © 2017年 devbool. All rights reserved.
//

#import "MBMatchProgram.h"

@implementation MBMatchProgram

- (instancetype)init {
    return [self initWithDictiotnary:nil];
}

- (instancetype)initWithDictiotnary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.detail_link = dictionary[NSStringFromSelector(@selector(detail_link))];
        self.program_id = dictionary[NSStringFromSelector(@selector(program_id))];
        self.program_date = ((NSNumber *)dictionary[NSStringFromSelector(@selector(program_date))]).integerValue;
        self.program_daytime = dictionary[NSStringFromSelector(@selector(program_daytime))];
        self.program_name = dictionary[NSStringFromSelector(@selector(program_name))];
        self.participants = dictionary[NSStringFromSelector(@selector(participants))];
        
        self.is_important = ({
            NSInteger intVal = -1;
            NSNumber *val = dictionary[NSStringFromSelector(@selector(is_important))];
            if (val) {
                intVal = [val isKindOfClass:[NSNumber class]]?[val integerValue]:[(NSString *)val integerValue];
            }
            intVal;
        });
        
        self.is_football = ({
            NSInteger intVal = -1;
            NSNumber *val = dictionary[NSStringFromSelector(@selector(is_football))];
            if (val) {
                intVal = [val isKindOfClass:[NSNumber class]]?[val integerValue]:[(NSString *)val integerValue];
            }
            intVal;
        });
        
        self.is_basketball = ({
            NSInteger intVal = -1;
            NSNumber *val = dictionary[NSStringFromSelector(@selector(is_basketball))];
            if (val) {
                intVal = [val isKindOfClass:[NSNumber class]]?[val integerValue]:[(NSString *)val integerValue];
            }
            intVal;
        });
        
        self.status = dictionary[NSStringFromSelector(@selector(status))];
        
        self.is_living = ({
            NSInteger intVal = -1;
            NSNumber *val = dictionary[NSStringFromSelector(@selector(is_living))];
            if (val) {
                intVal = [val isKindOfClass:[NSNumber class]]?[val integerValue]:[(NSString *)val integerValue];
            }
            intVal;
        });

        self.scores = dictionary[NSStringFromSelector(@selector(scores))];
    }
    return self;
}

- (void)fillPropertiesWithAnother:(MBMatchProgram *)anotherObj
          ignoreUnkownValueFields:(BOOL)ignoreUnkownValueFields {
    if (!anotherObj) return;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.detail_link)) self.detail_link = anotherObj.detail_link;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.program_id)) self.program_id = anotherObj.program_id;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.program_date > 0)) self.program_date = anotherObj.program_date;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.program_daytime)) self.program_daytime = anotherObj.program_daytime;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.program_name)) self.program_name = anotherObj.program_name;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.participants)) self.participants = anotherObj.participants;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.is_important >= 0)) self.is_important = anotherObj.is_important;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.is_football >= 0)) self.is_football = anotherObj.is_football;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.is_basketball >= 0)) self.is_basketball = anotherObj.is_basketball;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.status)) self.status = anotherObj.status;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.is_living >= 0)) self.is_living = anotherObj.is_living;
    if (!ignoreUnkownValueFields || (ignoreUnkownValueFields && anotherObj.scores)) self.scores = anotherObj.scores;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.detail_link = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(detail_link))];
        self.program_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(program_id))];
        self.program_date = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(program_date))];
        self.program_daytime = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(program_daytime))];
        self.program_name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(program_name))];
        self.participants = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(participants))];
        self.is_important = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(is_important))];
        self.is_football = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(is_football))];
        self.is_basketball = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(is_basketball))];
        self.status = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(status))];
        self.is_living = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(is_living))];
        self.scores = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(scores))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.detail_link forKey:NSStringFromSelector(@selector(detail_link))];
    [aCoder encodeObject:self.program_id forKey:NSStringFromSelector(@selector(program_id))];
    [aCoder encodeInteger:self.program_date forKey:NSStringFromSelector(@selector(program_date))];
    [aCoder encodeObject:self.program_daytime forKey:NSStringFromSelector(@selector(program_daytime))];
    [aCoder encodeObject:self.program_name forKey:NSStringFromSelector(@selector(program_name))];
    [aCoder encodeObject:self.participants forKey:NSStringFromSelector(@selector(participants))];
    [aCoder encodeInteger:self.is_important forKey:NSStringFromSelector(@selector(is_important))];
    [aCoder encodeInteger:self.is_football forKey:NSStringFromSelector(@selector(is_football))];
    [aCoder encodeInteger:self.is_basketball forKey:NSStringFromSelector(@selector(is_basketball))];
    [aCoder encodeObject:self.status forKey:NSStringFromSelector(@selector(status))];
    [aCoder encodeInteger:self.is_living forKey:NSStringFromSelector(@selector(is_living))];
    [aCoder encodeObject:self.scores forKey:NSStringFromSelector(@selector(scores))];
}

- (id)copyWithZone:(NSZone *)zone {
    MBMatchProgram *copyObj = [[MBMatchProgram allocWithZone:zone] init];
    copyObj.detail_link = self.detail_link;
    copyObj.program_id = self.program_id;
    copyObj.program_date = self.program_date;
    copyObj.program_daytime = self.program_daytime;
    copyObj.program_name = self.program_name;
    copyObj.participants = self.participants;
    copyObj.is_important = self.is_important;
    copyObj.is_football = self.is_football;
    copyObj.is_basketball = self.is_basketball;
    copyObj.status = self.status;
    copyObj.is_living = self.is_living;
    copyObj.scores = self.scores;
    return copyObj;
}

@end
