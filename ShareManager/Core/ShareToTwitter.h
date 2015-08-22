//
//  ShareToTwitter.h
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareManager.h"
#import <oauthconsumer/OAConsumer.h>
#import <oauthconsumer/OARequestParameter.h>
#import <oauthconsumer/OAServiceTicket.h>
#import <oauthconsumer/OADataFetcher.h>
#import <sys/types.h>
#import "SMContent.h"
#import "SMWebViewController.h"

#define TWITTER_ACCESS_TOKEN        @"twitter_access_token"
#define TWITTER_REQUEST_TOKEN_URL   @"https://api.twitter.com/oauth/request_token"
#define TWITTER_AUTHORIZE_URL       @"https://api.twitter.com/oauth/authorize"
#define TWITTER_UPLOAD_URL          @"https://upload.twitter.com/1.1/media/upload.json"
#define TWITTER_UPDATE_URL          @"https://api.twitter.com/1.1/statuses/update.json"
#define TWITTER_ACCESS_TOKEN_URL    @"https://api.twitter.com/oauth/access_token"

@class ShareToTwitter;
typedef void (^ShareTwitterBlock)(ShareContentState resultCode);
typedef void (^ObtainTwitterTokenBlock)(void);

@interface ShareToTwitter : NSObject
{
    ShareTwitterBlock  _completionBlock;
    ShareTwitterBlock  _failureBlock;
    ObtainTwitterTokenBlock _completionTokenBlock;
    ObtainTwitterTokenBlock _failureTokenBlock;
}

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectUri;

@property (nonatomic, strong) OAToken *requestToken;
@property (strong, nonatomic) OAToken *accessToken;

+ (ShareToTwitter *)sharedInstance;

- (void)initTwitterWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

#pragma mark - 获取access token
- (void)obtainAccessTokenWithCompletionBlock:(ObtainTwitterTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainTwitterTokenBlock)aFailedBlock;

#pragma mark - oauth方式分享
- (void)shareOAuthWithContent:(SMContent *)content
                  completionBlock:(ShareTwitterBlock)aCompletionBlock
                      failedBlock:(ShareTwitterBlock)aFailedBlock;
@end
