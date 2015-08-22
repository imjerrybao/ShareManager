//
//  UIColor+hex.h
//  CameraRuler
//
//  Created by Jerry on 13-4-23.
//  Copyright (c) 2013年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface UIColor (hex)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

+ (UIColor *)colorWithIntRed:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;
+ (UIColor *)colorWithIntRed:(int)red green:(int)green blue:(int)blue;
@end
