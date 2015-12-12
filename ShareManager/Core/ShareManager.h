//
//  AppDelegate.h
//  ShareManager
//
//  Created by Jerry on 12/17/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ShareToTencentQQ.h"
#import "ShareToWeixin.h"
#import "ShareToWeibo.h"
#import "ShareToFacebook.h"
#import "ShareToTwitter.h"
#import "ShareToInstagram.h"
#import "SMContent.h"
#import "SMImage.h"
#import "SMIcon.h"
#import "ShareUI.h"
#import "SMWebViewController.h"
#import "SMConstant.h"
#import "SMShareResult.h"

#define SHARE_TITLE_LENGTH 20
#define SHARE_CONTENT_LENGTH 140

@protocol ShareManagerDelegate <NSObject>
@optional
- (void)showShareResult:(SMShareResult *)result;
@end

typedef void (^ShareFinishBlock)(void);
@class ShareManager;
typedef void (^ShareManagerBlock)(ShareContentState resultCode);

@interface ShareManager : NSObject <ShareUIDelegate>

@property (nonatomic, weak) UIViewController *presentViewController; //Presented View Controller

@property (nonatomic, assign) id<ShareManagerDelegate> shareDelegate; //ShareManager Delegate

@property (nonatomic, strong) NSArray *usedPlatforms;

/**
 *  Get ShareManager Singleton
 *
 *  @return ShareManager Singleton
 */
+ (ShareManager *)sharedManager;

/**
 *  Initialize QQ Platform
 *
 *  @param appKey    QQ App Key
 *  @param appSecret QQ App Secret
 */
- (void)initTencentQQWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

/**
 *  Initialize Wechat Platform
 *
 *  @param appKey    Wechat App Key
 *  @param appSecret Wechat App Secret
 */
- (void)initWexinWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

/**
 *  Initialize Weibo Platform
 *
 *  @param appKey      Weibo App Key
 *  @param appSecret   Weibo App Secret
 *  @param redirectUri Weibo Redirect Uri
 */
- (void)initWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

/**
 *  Initialize Twitter Platform
 *
 *  @param appKey      Twitter App Key
 *  @param appSecret   Twitter App Secret
 *  @param redirectUri Twitter Redirect Uri
 */
- (void)initTwitterWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

/**
 *  Initialize Facebook Platform
 *
 *  @param appKey      Facebook App Key
 *  @param appSecret   Facebook App Secret
 *  @param redirectUri Facebook Redirect Uri
 */
- (void)initFacebookWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

/**
 *  The Platforms To Share
 *
 *  @param platforms Platforms
 */
- (void)usePlatforms:(NSArray *)platforms;

/**
 *  Initialize Instagram Platform
 */
- (void)initInstagram;

/**
 *  Open A Resource Identified By URL
 *
 *  @param url The URL of Resource
 *
 *  @return Should Open The URL or Not
 */
- (BOOL) handleOpenURL:(NSURL *) url;

/**
 *  Initialize The Shared Content
 *
 *  @param title       Title of Share Content (Only Support QQ and Wechat)
 *  @param description Description of Share Content
 *  @param image       Image of Share Content
 *  @param url         Url of Share Content
 */
- (void)setContentWithTitle:(NSString *)title
                description:(NSString*)description
                      image:(SMImage *)image
                        url:(NSString *)url;

/**
 *  Show Share Pop Window
 */
- (void)showShareWindow;

/**
 *  Share Content To A Platform
 *
 *  @param platform     Specified Platform
 *  @param successBlock Success Block
 *  @param failBlock    Fail Block
 */
- (void)shareContentToPlatform:(SMPlatform)platform
                  successBlock:(ShareManagerBlock)successBlock
                     failBlock:(ShareManagerBlock)failBlock;

/**
 *  Get A Platform's Access Token
 *
 *  @param platform     Specified Platform
 *  @param successBlock Success Block
 *  @param failBlock    Fail Block
 */
- (void)obtainAccessTokenWithPlatform:(SMPlatform)platform
                         successBlock:(void(^)(void))successBlock
                            failBlock:(void(^)(void))failBlock;

/**
 *  Batch Share Content To Platforms
 *
 *  @param shareList Platforms List
 */
- (void)batchShareWithShareList:(NSMutableArray *)shareList;


/**
 *  Check If Is Authorized A Platform
 *
 *  @param platform Specified Platform
 *
 *  @return Auth Status
 */
+ (BOOL)isAuthPlatform:(SMPlatform)platform;

/**
 *  Remove Access Token Of A Platform
 *
 *  @param platform Specified Platform
 */
+ (void)removeAuthWithPlatform:(SMPlatform)platform;

/**
 *  Get Authorized Platform List
 *
 *  @return Authorized Platform List
 */
+ (NSArray *)authPlatformList;

@end
