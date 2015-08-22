//
//  ShareContent.h
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SMConstant.h"
#import "SMImage.h"

@interface SMContent : NSObject
@property (nonatomic, strong) NSString *title;  //仅对qq和微信有效
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) SMImage *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) UIView *view;
@end
