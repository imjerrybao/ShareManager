//
//  ShareContent.h
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 __CompanyName__ All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SMConstant.h"
#import "SMImage.h"

@interface SMContent : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) SMImage *image;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) SMMediaType mediaType;
//@property (nonatomic, strong) PersonalRecord *personalRecord;
@property (nonatomic, weak) UIView *view;
@end
