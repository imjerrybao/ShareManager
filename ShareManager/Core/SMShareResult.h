//
//  ShareResult.h
//  ShareManagerDemo
//
//  Created by apple on 8/22/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMConstant.h"

@interface SMShareResult : NSObject
@property (nonatomic, assign) SMPlatform platform;
@property (nonatomic, assign) ShareContentState state;
@end
