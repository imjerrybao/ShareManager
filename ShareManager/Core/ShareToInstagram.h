//
//  ShareToInstagram.h
//  ShareManagerDemo
//
//  Created by apple on 9/9/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SMConstant.h"
#import "SMContent.h"
#import "SMWebViewController.h"

#define INSTAGRAM_ACCESS_TOKEN          @"instagram_access_token"

@class ShareToFacebook;
typedef void (^ShareInstagramBlock)(ShareContentState resultCode);
typedef void (^ObtainInstagramTokenBlock)(void);

@interface ShareToInstagram : NSObject
{
    ShareInstagramBlock          _completionBlock;
    ShareInstagramBlock          _failureBlock;
    ObtainInstagramTokenBlock    _completionTokenBlock;
    ObtainInstagramTokenBlock    _failureTokenBlock;
}

extern NSString* const aInstagramAppURLString;
extern NSString* const aInstagramOnlyPhotoFileName;

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectUri;

@property (strong, nonatomic) NSString *accessToken;

+ (ShareToInstagram *)sharedInstance;

- (void)initInstagram;

+ (void) setPhotoFileName:(NSString*)fileName;
+ (NSString*) photoFileName;

+ (BOOL) isAppInstalled;
+ (BOOL) isImageCorrectSize:(UIImage*)image;
- (void) postImage:(UIImage*)image inView:(UIView*)view;
- (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view;
- (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;

@end
