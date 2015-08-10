//
//  UIColor+hex.m
//  CameraRuler
//
//  Created by Jerry on 13-4-23.
//  Copyright (c) 2013年 Jerry. All rights reserved.
//

#import "UIColor+hex.h"

@implementation UIColor (hex)

+ (UIColor*) colorWithHex:(long)hexColor {
    return [UIColor colorWithHex:hexColor alpha:1.0];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

+ (UIColor *)colorWithIntRed:(int)red green:(int)green blue:(int)blue alpha:(float)opacity {
    float _red = red / 255.0, _green = green / 255.0, _blue = blue / 255.0;
    return [UIColor colorWithRed:_red green:_green blue:_blue alpha:opacity];
}

+ (UIColor *)colorWithIntRed:(int)red green:(int)green blue:(int)blue {
    return [UIColor colorWithIntRed:red green:green blue:blue alpha:1.0];
}
@end
