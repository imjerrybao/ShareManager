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
//#import "ShareToWeixin.h"
#import "ShareToWeibo.h"
#import "ShareToFacebook.h"
#import "ShareToTwitter.h"
#import "SMContent.h"
#import "SMImage.h"
#import "SMIcon.h"
#import "ShareUI.h"
#import "SMWebViewController.h"
#import "SMConfig.h"

#define SHARE_TITLE_LENGTH 20
#define SHARE_CONTENT_LENGTH 140
typedef void (^ShareFinishBlock)(void);
@class ShareManager;
typedef void (^ShareManagerBlock)(ShareContentState resultCode);

@interface ShareManager : NSObject <ShareUIDelegate>

@property (nonatomic, strong) NSString *tencentQQAppKey;

@property (nonatomic, strong) NSString *weixinAppKey;

@property (nonatomic, strong) NSString *weiboAppKey;
@property (nonatomic, strong) NSString *weiboAppSecret;
@property (nonatomic, strong) NSString *weiboRedirectUri;

@property (nonatomic, strong) NSString *twitterAppKey;
@property (nonatomic, strong) NSString *twitterAppSecret;
@property (nonatomic, strong) NSString *twitterRedirectUri;

@property (nonatomic, strong) NSString *facebookAppKey;
@property (nonatomic, strong) NSString *facebookAppSecret;
@property (nonatomic, strong) NSString *facebookRedirectUri;

@property (nonatomic, strong) SMContent *shareContent;
@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) ShareUI *shareUI;
@property (nonatomic, weak) UIViewController *presentViewController;

@property (nonatomic, copy) ShareFinishBlock shareFinishBlock;

+ (ShareManager *)sharedManager;

#pragma mark - 初始化分享平台
- (void)initTencentQQWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)initWexinWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)initWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;
- (void)initTwitterWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;
- (void)initFacebookWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri;

#pragma mark - 调用客户端的处理
-(BOOL) handleOpenURL:(NSURL *) url;

#pragma mark - 生成分享内容
/**
 *  初始化分享内容
 *
 *  @param title       标题，只在QQ和微信中有效
 *  @param description 内容
 *  @param image       图片
 *  @param url         链接，只在QQ和微信中有效
 *  @param mediaType   分享类型
 *
 *  @return void
 */
- (void)setContentWithTitle:(NSString *)title
                description:(NSString*)description
                      image:(SMImage *)image
                        url:(NSString *)url;

#pragma 弹窗选择平台单个分享actions
- (void)showShareWindow;
- (void)shareContentToPlatform:(SMPlatform)platform
                  successBlock:(ShareManagerBlock)successBlock
                     failBlock:(ShareManagerBlock)failBlock;

#pragma mark - 一键分享actions
- (void)obtainAccessTokenWithPlatform:(SMPlatform)platform
                         successBlock:(void(^)(void))successBlock
                            failBlock:(void(^)(void))failBlock;
- (void)batchShareWithShareList:(NSMutableArray *)shareList;

#pragma mark - 网页显示页面

- (void)setPresentViewController:(UIViewController *)presentViewController;


/**
 *  是否绑定分享平台
 *
 *  @param platform 分享平台
 *
 *  @return 绑定状态
 */
+ (BOOL)isAuthPlatform:(SMPlatform)platform;

@end
