//
//  ShareUI.h
//  ShareManager
//
//  Created by Jerry on 12/31/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SMIcon.h"
#import "SMConstant.h"

@protocol ShareUIDelegate <NSObject>

- (void)shareToPlatform:(SMPlatform)platform;

@end

@interface ShareUI : NSObject
@property (nonatomic, assign) id<ShareUIDelegate> delegate;
@property (nonatomic, weak) UIView *shareWindowBackView;
@property (nonatomic, weak) UIView *shareWindow;
@property (nonatomic, weak) UIView *shareWindowArea;

+ (ShareUI *)sharedInstance;
- (void)showShareWindowWithImageList:(NSArray *)shareImageList titleList:(NSArray *)shareTitleList tagList:(NSArray *)shareTagList;
- (void)cancelAction;
@end
