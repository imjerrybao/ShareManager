//
//  NSString+util.m
//  ShareManager
//
//  Created by Jerry on 13-4-26.
//  Copyright (c) 2013年 Jerry. All rights reserved.
//

#import "NSString+util.h"

@implementation NSString (util)

+ (BOOL) isBlankString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]])
    {
        return YES;
    }
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
