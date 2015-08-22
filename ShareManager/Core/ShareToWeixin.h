//
//  ShareToWeixin.h
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "SMConstant.h"
#import "SMContent.h"

#define WEIXIN_ACCESS_TOKEN          @"weixin_access_token"

@class ShareToWeixin;
typedef void (^ShareWeixinBlock)(ShareContentState resultCode);
typedef void (^ObtainWeixinTokenBlock)(void);

typedef enum {
    WXSceneTypeSession   = 0,
    WXSceneTypeTimeline  = 1
}WXSceneTypeE;

@interface ShareToWeixin : NSObject <WXApiDelegate>
{
    ShareWeixinBlock          _completionBlock;
    ShareWeixinBlock          _failureBlock;
    ObtainWeixinTokenBlock    _completionTokenBlock;
    ObtainWeixinTokenBlock    _failureTokenBlock;
}

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *code;

+ (ShareToWeixin *)sharedInstance;

- (void)initWeixinWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (BOOL)handleOpenURL:(NSURL *) url;

#pragma mark - 获取绑定授权
- (void)obtainAccessTokenWithCompletionBlock:(ObtainWeixinTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainWeixinTokenBlock)aFailedBlock;

#pragma mark - sdk方式分享
- (void) shareWithContent:(SMContent *)content
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareWeixinBlock)aCompletionBlock
                  failedBlock:(ShareWeixinBlock)aFailedBlock;

@end
