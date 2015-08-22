//
//  ShareToWeibo.h
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SMConstant.h"
#import "SMContent.h"
#import "SMWebViewController.h"

#define FACEBOOK_ACCESS_TOKEN          @"facebook_access_token"
#define FACEBOOK_AUTHORIZE_URL         @"https://www.facebook.com/dialog/oauth"
#define FACEBOOK_ACCESS_TOKEN_URL      @"https://graph.facebook.com/oauth/access_token"
#define FACEBOOK_UPLOAD_URL            @"https://graph.facebook.com/v2.2/me/photos"
#define FACEBOOK_UPDATE_URL            @"https://graph.facebook.com/v2.2/me/feed"


@class ShareToFacebook;
typedef void (^ShareFacebookBlock)(ShareContentState resultCode);
typedef void (^ObtainFacebookTokenBlock)(void);

@interface ShareToFacebook : NSObject
{
    ShareFacebookBlock          _completionBlock;
    ShareFacebookBlock          _failureBlock;
    ObtainFacebookTokenBlock    _completionTokenBlock;
    ObtainFacebookTokenBlock    _failureTokenBlock;
}

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectUri;

@property (strong, nonatomic) NSString *accessToken;

+ (ShareToFacebook *)sharedInstance;


- (void)initFacebookWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

- (void)obtainAccessTokenWithCompletionBlock:(void(^)(void))successBlock
                                 failedBlock:(void(^)(void))failedBlock;

- (void)shareOAuthWithContent:(SMContent *)content
                  completionBlock:(ShareFacebookBlock)aCompletionBlock
                      failedBlock:(ShareFacebookBlock)aFailedBlock;

@end
