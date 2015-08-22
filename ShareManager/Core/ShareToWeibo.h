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

#define WEIBO_ACCESS_TOKEN          @"weibo_access_token"
#define WEIBO_AUTHORIZE_URL         @"https://api.weibo.com/oauth2/authorize"
#define WEIBO_ACCESS_TOKEN_URL      @"https://api.weibo.com/oauth2/access_token"
#define WEIBO_UPLOAD_URL            @"https://upload.api.weibo.com/2/statuses/upload.json"
#define WEIBO_UPDATE_URL            @"https://api.weibo.com/2/statuses/update.json"

@protocol ShareToWeiboDelegate <NSObject>

@required
- (void)didChangeWeiboSelectionState:(BOOL)isSelected;

@end


@class ShareToWeibo;
typedef void (^ShareWeiboBlock)(ShareContentState resultCode);
typedef void (^ObtainWeiboTokenBlock)(void);

@interface ShareToWeibo : NSObject
{
    ShareWeiboBlock          _completionBlock;
    ShareWeiboBlock          _failureBlock;
    ObtainWeiboTokenBlock    _completionTokenBlock;
    ObtainWeiboTokenBlock    _failureTokenBlock;
}

@property (nonatomic, assign) id<ShareToWeiboDelegate> delegate;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectUri;

@property (strong, nonatomic) NSString *accessToken;

+ (ShareToWeibo *)sharedInstance;


- (void)initWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

#pragma mark - oauth方式分享
- (void)obtainAccessTokenWithCompletionBlock:(ObtainWeiboTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainWeiboTokenBlock)aFailedBlock;

- (void)shareOAuthWithContent:(SMContent *)content
                  completionBlock:(ShareWeiboBlock)aCompletionBlock
                      failedBlock:(ShareWeiboBlock)aFailedBlock;

@end
