//
//  ShareToTencentQQ.h
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "SMConstant.h"
#import "SMContent.h"

#define TENCENTQQ_ACCESS_TOKEN          @"tencentqq_access_token"
#define TENCENTANGLER_ACCESS_TOKEN      @"TENCENTANGLER_ACCESS_TOKEN"

@class ShareToTencentQQ;
typedef void (^ShareQQBlock)(ShareContentState resultCode);
typedef void (^ObtainQQTokenBlock)(void);

@interface ShareToTencentQQ : NSObject <TencentSessionDelegate>
{
    ShareQQBlock          _completionBlock;
    ShareQQBlock          _failureBlock;
    ObtainQQTokenBlock    _completionTokenBlock;
    ObtainQQTokenBlock    _failureTokenBlock;
}
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, retain) TencentOAuth *tencentOAuth;

+ (ShareToTencentQQ *)sharedInstance;

- (void)initTencentQQWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (BOOL)handleOpenURL:(NSURL *) url;

#pragma mark - 获取绑定授权
- (void)obtainAccessTokenWithCompletionBlock:(ObtainQQTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainQQTokenBlock)aFailedBlock;

//Share via QQ
- (void)shareWithContent:(SMContent *)content
             completionBlock:(ShareQQBlock)aCompletionBlock
                 failedBlock:(ShareQQBlock)aFailedBlock;

@end
