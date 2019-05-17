//
//  NSString+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/3/15.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TDKit)

/**
 Trim blank characters (space and newline) in head and tail.
 @return the trimmed string.
 */
- (NSString *)stringByTrim;

/**
 nil, @"", @"  ", @"\n" will Returns NO; otherwise Returns YES.
 */
- (BOOL)isNotBlank;

/**
 Returns YES if the target string is contained within the receiver.
 @param string A string to test the the receiver.
 
 @discussion Apple has implemented this method in iOS8.
 */
- (BOOL)containsString:(NSString *)string;

/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
- (NSString *)stringByURLEncode;

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)stringByURLDecode;

/**
 Some string may encode several times. so entirely URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)stringByURLDecodeEntirely:(BOOL)entirely;

/**
 Escape commmon HTML to Entity.
 Example: "x<y" will be escape to "x&lt;y".
 */
- (NSString *)stringByEscapingHTML;

/**
 Returns a new UUID NSString
 e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"
 */
+ (NSString *)stringWithUUID;


/**
 Detect languages of this string, hold by `containEnglish` and `containOthers`.

 @param englishTagsNum  the number of English characters ranges
 @param otherTagsNum  the number of other (non English) characters ranges
 */
- (void)detectLanguagesWithEnglishTagsNum:(NSUInteger *)englishTagsNum
                             otherTagsNum:(NSUInteger *)otherTagsNum;

@end
