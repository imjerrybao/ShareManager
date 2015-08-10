//
//  UIView+size.h
//  ShareManager
//
//  Created by Jerry on 13-4-23.
//  Copyright (c) 2013年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (size)

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end
