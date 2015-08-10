//
//  NSString+util.h
//  ShareManager
//
//  Created by Jerry on 13-4-26.
//  Copyright (c) 2013年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 返回字符串s第一个字的gbk编码值
 */
extern uint64_t gbk_value(NSString *s);
extern uint64_t shiftjis_value(NSString *s);
extern uint64_t unicode_value(NSString *s);

@interface NSString (util)

+ (BOOL)isBlankString:(NSString *)string;

@end
