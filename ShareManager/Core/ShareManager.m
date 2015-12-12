//
//  AppDelegate.h
//  ShareManager
//
//  Created by Jerry on 12/17/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareManager.h"
#define ShareImageList    @[@"sns_weibo", @"sns_qzone", @"sns_weixin", @"sns_facebook", @"sns_twitter", @"sns_instagram"]
#define ShareTitleList    @[Locale(@"sm.weibo"), Locale(@"sm.qzone"), Locale(@"sm.weixin"), Locale(@"sm.facebook"), Locale(@"sm.twitter"), Locale(@"sm.instagram")]
#define ShareTagList      @[@(SMPlatformWeiboOAuth), @(SMPlatformTencentQQ), @(SMPlatformWeixin), @(SMPlatformFacebookOAuth), @(SMPlatformTwitterOAuth), @(SMPlatformInstagram)]


@interface ShareManager ()
@property (nonatomic, strong) NSString *tencentQQAppKey; //QQ App Key

@property (nonatomic, strong) NSString *weixinAppKey; //Wechat App Key

@property (nonatomic, strong) NSString *weiboAppKey; //Weibo App Key
@property (nonatomic, strong) NSString *weiboAppSecret; //Weibo App Secret
@property (nonatomic, strong) NSString *weiboRedirectUri; //Weibo Redirect Uri

@property (nonatomic, strong) NSString *twitterAppKey; //Twitter App Key
@property (nonatomic, strong) NSString *twitterAppSecret; //Twitter App Secret
@property (nonatomic, strong) NSString *twitterRedirectUri; //Twitter Redirect Uri

@property (nonatomic, strong) NSString *facebookAppKey; //Facebook App Key
@property (nonatomic, strong) NSString *facebookAppSecret; //Facebook App Secret
@property (nonatomic, strong) NSString *facebookRedirectUri; //Facebook Redirect Uri

@property (nonatomic, strong) SMContent *shareContent; //The Content to Share
@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) ShareUI *shareUI;

@property (nonatomic, copy) ShareFinishBlock shareFinishBlock;

@property (nonatomic, assign) int index;

@property (nonatomic, strong) NSMutableArray *shareImageList;
@property (nonatomic, strong) NSMutableArray *shareTitleList;
@property (nonatomic, strong) NSMutableArray *shareTagList;

@end

@implementation ShareManager

+ (ShareManager *)sharedManager
{
    static ShareManager   *shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ShareManager alloc] init];
    });
    return shareManager;
}

- (id)init{
    self = [super init];
    if (self) {
        _index = 0;
        _shareImageList = [NSMutableArray array];
        _shareTitleList = [NSMutableArray array];
        _shareTagList = [NSMutableArray array];
    }
    return self;
}

- (void)setShareContent:(SMContent *)shareContent
{
    _shareContent = shareContent;
    if (![NSString isBlankString:_shareContent.url]) {
        _shareContent.desc = [NSString stringWithFormat:@"%@ %@", _shareContent.url, _shareContent.desc];
    }
}

- (void)initTencentQQWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    [[ShareToTencentQQ sharedInstance] initTencentQQWithAppKey:appKey appSecret:appSecret];
    _tencentQQAppKey = appKey;
}
- (void)initWexinWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    [[ShareToWeixin sharedInstance] initWeixinWithAppKey:appKey appSecret:appSecret];
    _weixinAppKey = appKey;
}
- (void)initWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    [[ShareToWeibo sharedInstance] initWeiboWithAppKey:appKey appSecret:appSecret redirectUri:redirectUri];
    _weiboAppKey = appKey;
    _weiboAppSecret = appSecret;
    _weiboRedirectUri = redirectUri;
}
- (void)initTwitterWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    [[ShareToTwitter sharedInstance] initTwitterWithAppKey:appKey appSecret:appSecret redirectUri:redirectUri];
    _twitterAppKey = appKey;
    _twitterAppSecret = appSecret;
    _twitterRedirectUri = redirectUri;
}
- (void)initFacebookWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    [[ShareToFacebook sharedInstance] initFacebookWithAppKey:appKey appSecret:appSecret redirectUri:redirectUri];
    _facebookAppKey = appKey;
    _facebookAppSecret = appSecret;
    _facebookRedirectUri = redirectUri;
}
- (void)initInstagram
{
    [[ShareToInstagram sharedInstance] initInstagram];
}
- (void)usePlatforms:(NSArray *)platforms
{
    _usedPlatforms = [NSArray arrayWithArray:platforms];
    for (id platform in _usedPlatforms) {
        switch ([platform integerValue]) {
            case SMPlatformFacebookOAuth:
            {
                [_shareImageList addObject:@"sns_facebook"];
                [_shareTitleList addObject:Locale(@"sm.facebook")];
                [_shareTagList addObject:@(SMPlatformFacebookOAuth)];
            }
                break;
            case SMPlatformTwitterOAuth:
            {
                [_shareImageList addObject:@"sns_twitter"];
                [_shareTitleList addObject:Locale(@"sm.twitter")];
                [_shareTagList addObject:@(SMPlatformTwitterOAuth)];
            }
                break;
            case SMPlatformInstagram:
            {
                [_shareImageList addObject:@"sns_instagram"];
                [_shareTitleList addObject:Locale(@"sm.instagram")];
                [_shareTagList addObject:@(SMPlatformInstagram)];
            }
                break;
            case SMPlatformWeiboOAuth:
            {
                [_shareImageList addObject:@"sns_weibo"];
                [_shareTitleList addObject:Locale(@"sm.weibo")];
                [_shareTagList addObject:@(SMPlatformWeiboOAuth)];
            }
                break;
            case SMPlatformTencentQQ:
            {
                [_shareImageList addObject:@"sns_qzone"];
                [_shareTitleList addObject:Locale(@"sm.qzone")];
                [_shareTagList addObject:@(SMPlatformTencentQQ)];
            }
                break;
            case SMPlatformWeixin:
            {
                [_shareImageList addObject:@"sns_weixin"];
                [_shareTitleList addObject:Locale(@"sm.weixin")];
                [_shareTagList addObject:@(SMPlatformWeixin)];
            }
                break;
                
            default:
                break;
        }
    }
}


-(BOOL) handleOpenURL:(NSURL *) url
{
    NSLog(@"handleOpenURL: %@",url.absoluteString);
    //TencentQQ
    NSRange r = [url.absoluteString rangeOfString:_tencentQQAppKey];
    if (r.location != NSNotFound) {
        return [[ShareToTencentQQ sharedInstance] handleOpenURL:url];
    }
    //Weixin
    r = [url.absoluteString rangeOfString:_weixinAppKey];
    if (r.location != NSNotFound) {
        return [[ShareToWeixin sharedInstance] handleOpenURL:url];
    }
    return NO;
}

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
                               url:(NSString *)url
{
    SMContent *content = [[SMContent alloc] init];
    content.title = title;
    content.desc = description;
    content.image = image;
    content.url = url;
//    content.personalRecord = personalRecord;
    _shareContent = content;
}

#pragma 弹窗选择平台单个分享actions
#pragma mark - ShareUIDelegate
- (void)shareToPlatform:(SMPlatform)platform
{
    [[ShareUI sharedInstance] cancelAction];
    [self shareContentToPlatform:platform
                    successBlock:^(ShareContentState resultCode) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_shareContent.view)
                            {
                                [MBProgressHUD hideHUDForView:_shareContent.view animated:YES];
                            }
                        });
                        
                    } failBlock:^(ShareContentState resultCode) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_shareContent.view)
                            {
                                [MBProgressHUD hideHUDForView:_shareContent.view animated:YES];
                            }
                        });
                    }];
}
- (void)showShareWindow
{
    [[ShareUI sharedInstance] showShareWindowWithImageList:_shareImageList titleList:_shareTitleList tagList:_shareTagList];
    [ShareUI sharedInstance].delegate = self;
}

#pragma mark -  单个平台分享
- (void)shareContentToPlatform:(SMPlatform)platform
                  successBlock:(ShareManagerBlock)successBlock
                     failBlock:(ShareManagerBlock)failBlock
{
    if (!_shareContent) {
        NSLog(@"没有填写分享内容，先调用setShareContent设置");
        return;
    }
    [self share:platform successBlock:successBlock failBlock:failBlock];
}

- (void)share:(SMPlatform)platform
                  successBlock:(ShareManagerBlock)successBlock
                     failBlock:(ShareManagerBlock)failBlock
{
    switch (platform) {
        case SMPlatformTencentQQ:
        {
            [[ShareToTencentQQ sharedInstance] shareWithContent:_shareContent
                                                    completionBlock:^(ShareContentState resultCode) {
                                                        
                                                        if (successBlock) {
                                                            successBlock(resultCode);
                                                         }
                                                        [self showShareResultWithPlatform:SMPlatformTencentQQ state:ShareContentStateSuccess];
                                                        
                                                    } failedBlock:^(ShareContentState resultCode) {
                                                        
                                                        if (failBlock) {
                                                            failBlock(resultCode);
                                                        }
                                                        
                                                        if (resultCode == ShareContentStateUnInstalled) {
                                                            
                                                            [self showShareResultWithPlatform:SMPlatformTencentQQ state:ShareContentStateUnInstalled];
                                                            
                                                        }else{
                                                            
                                                            [self showShareResultWithPlatform:SMPlatformTencentQQ state:ShareContentStateFail];
                                                            
                                                        }
                                                    }];
        }
            break;
        case SMPlatformWeixin:
        {
            [[ShareToWeixin sharedInstance] shareWithContent:_shareContent
                                                           scene:WXSceneTypeTimeline
                                                 completionBlock:^(ShareContentState resultCode) {
                                                     
                                                     if (successBlock) {
                                                         successBlock(resultCode);
                                                     }
                                                     [self showShareResultWithPlatform:SMPlatformWeixin state:ShareContentStateSuccess];
                                                     
                                                 } failedBlock:^(ShareContentState resultCode) {
                                                     
                                                     if (failBlock) {
                                                         failBlock(resultCode);
                                                     }
                                                     if (resultCode == ShareContentStateUnInstalled) {
                                                         
                                                         [self showShareResultWithPlatform:SMPlatformWeixin state:ShareContentStateUnInstalled];
                                                         
                                                     }else{
                                                         
                                                         [self showShareResultWithPlatform:SMPlatformWeixin state:ShareContentStateFail];
                                                     }
                                                 }];
        }
            break;
//        case SMPlatformWeibo:
        case SMPlatformWeiboOAuth:
        {
            [[ShareToWeibo sharedInstance] shareOAuthWithContent:_shareContent
                                                     completionBlock:^(ShareContentState resultCode) {
                                                         
                                                         if (successBlock) {
                                                             successBlock(resultCode);
                                                         }
                                                         [self showShareResultWithPlatform:SMPlatformWeiboOAuth state:ShareContentStateSuccess];
                                                         
                                                     } failedBlock:^(ShareContentState resultCode) {
                                                         if (failBlock) {
                                                             failBlock(resultCode);
                                                         }
                                                         [self showShareResultWithPlatform:SMPlatformWeiboOAuth state:ShareContentStateFail];
                                                     }];
            
        }
            break;
//        case SMPlatformFacebook:
        case SMPlatformFacebookOAuth:
        {
            [[ShareToFacebook sharedInstance] shareOAuthWithContent:_shareContent
                                                        completionBlock:^(ShareContentState resultCode) {
                                                            
                                                            if (successBlock) {
                                                                successBlock(resultCode);
                                                            }
                                                            [self showShareResultWithPlatform:SMPlatformFacebookOAuth state:ShareContentStateSuccess];
                                                            
                                                        } failedBlock:^(ShareContentState resultCode) {
                                                            
                                                            if (failBlock) {
                                                                failBlock(resultCode);
                                                            }
                                                            [self showShareResultWithPlatform:SMPlatformFacebookOAuth state:ShareContentStateFail];
                                                        }];
        }
            break;
        case SMPlatformTwitterOAuth:
        {
            [[ShareToTwitter sharedInstance] shareOAuthWithContent:_shareContent
                                                       completionBlock:^(ShareContentState resultCode) {
                                                           
                                                           if (successBlock) {
                                                               successBlock(resultCode);
                                                           }
                                                           [self showShareResultWithPlatform:SMPlatformTwitterOAuth state:ShareContentStateSuccess];
                                                           
                                                       } failedBlock:^(ShareContentState resultCode) {
                                                           
                                                           if (failBlock) {
                                                               failBlock(resultCode);
                                                           }
                                                           [self showShareResultWithPlatform:SMPlatformTwitterOAuth state:ShareContentStateFail];
                                                           
                                                       }];
            
        }
            break;
        case SMPlatformInstagram:
        {
            if (![ShareToInstagram isAppInstalled]) {
                UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:Locale(@"sm.general.hint") message:Locale(@"sm.shareto.instagram.notinstall")];
                [alertView bk_setCancelButtonWithTitle:Locale(@"sm.general.ok") handler:^{
                    if (self.shareFinishBlock) {
                        self.shareFinishBlock();
                    }
                }];
                [alertView show];
                return;
            }
            [[ShareToInstagram sharedInstance] postImage:_shareContent.image.compressedImage withCaption:_shareContent.title inView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 一键分享actions
- (void)obtainAccessTokenWithPlatform:(SMPlatform)platform
                         successBlock:(void(^)(void))successBlock
                            failBlock:(void(^)(void))failBlock
{
    switch (platform) {
//        case SMPlatformFacebook:
        case SMPlatformFacebookOAuth:
        {
            [[ShareToFacebook sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                                                 NSLog(@"obtain access token success");
                                                 if (successBlock) {
                                                     successBlock();
                                                 }
                                             } failedBlock:^ {
                                                 NSLog(@"obtain access token fail");
                                                 if (failBlock) {
                                                     failBlock();
                                                 }
                                             }];
        }
            break;
        case SMPlatformTwitterOAuth:
        {
            [[ShareToTwitter sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                
                                                   NSLog(@"obtain access token success");
                                                   if (successBlock) {
                                                       successBlock();
                                                   }
                                                } failedBlock:^ {
                                                    
                                                    NSLog(@"obtain access token fail");
                                                    if (failBlock) {
                                                        failBlock();
                                                    }
                                                }];
            
        }
            break;
//        case SMPlatformWeibo:
        case SMPlatformWeiboOAuth:
        {
            [[ShareToWeibo sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                                                 NSLog(@"obtain access token success");
                                                 if (successBlock) {
                                                     successBlock();
                                                 }
                                             } failedBlock:^ {
                                                 NSLog(@"obtain access token fail");
                                                 if (failBlock) {
                                                     failBlock();
                                                 }
                                             }];
        }
            break;
        case SMPlatformTencentQQ:
        {
            [[ShareToTencentQQ sharedInstance] obtainAccessTokenWithCompletionBlock:^{
                NSLog(@"obtain access token success");
                if (successBlock) {
                    successBlock();
                }
            } failedBlock:^{
                NSLog(@"obtain access token fail");
                if (failBlock) {
                    failBlock();
                }
            }];
        }
            break;
        case SMPlatformWeixin:
        {
            [[ShareToWeixin sharedInstance] obtainAccessTokenWithCompletionBlock:^{
                NSLog(@"obtain access token success");
                if (successBlock) {
                    successBlock();
                }
            } failedBlock:^{
                NSLog(@"obtain access token fail");
                if (failBlock) {
                    failBlock();
                }
            }];
        }
            break;
        default:
            break;
    }

}
- (void)batchShareWithShareList:(NSMutableArray *)shareList
{
    if(shareList.count == 0)return;
    [self didBatchShareWithShareList:shareList index:0];
}
- (void)didBatchShareWithShareList:(NSMutableArray *)shareList index:(NSInteger)i
{
    NSInteger platform = [shareList[i] integerValue];
    NSInteger count = shareList.count;
    
    [self shareContentToPlatform:platform
                    successBlock:^(ShareContentState resultCode) {
                    
                        if (i < count-1) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self didBatchShareWithShareList:shareList index:i+1];
                            });
                        }
                        
                    } failBlock:^(ShareContentState resultCode) {
                       
                        if (i < count-1) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self didBatchShareWithShareList:shareList index:i+1];
                            });
                        }
                    }];
}
- (void)showShareResultWithPlatform:(SMPlatform)platform state:(ShareContentState)state
{
    if ([self.shareDelegate respondsToSelector:@selector(showShareResult:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SMShareResult *result = [SMShareResult new];
            result.platform = platform;
            result.state = state;
            [self.shareDelegate performSelector:@selector(showShareResult:) withObject:result];
        });
        return;
    }
    
    NSString *message;
    switch (platform) {
        case SMPlatformFacebookOAuth:
            if (state == ShareContentStateSuccess) {
                message = Locale(@"sm.shareto.facebook.success");
            } else {
                message = Locale(@"sm.shareto.facebook.fail");
            }
            break;
        case SMPlatformTwitterOAuth:
            if (state == ShareContentStateSuccess) {
                message = Locale(@"sm.shareto.twitter.success");
            } else {
                message = Locale(@"sm.shareto.twitter.fail");
            }
            break;
        case SMPlatformWeiboOAuth:
            if (state == ShareContentStateSuccess) {
                message = Locale(@"sm.shareto.weibo.success");
            } else {
                message = Locale(@"sm.shareto.weibo.fail");
            }
            break;
        case SMPlatformWeixin:
            if (state == ShareContentStateSuccess) {
                message = Locale(@"sm.shareto.weixin.success");
            } else {
                if (state == ShareContentStateUnInstalled) {
                    message = Locale(@"sm.shareto.weixin.notinstall");
                } else {
                    message = Locale(@"sm.shareto.weixin.fail");
                }
            }
            break;
        case SMPlatformTencentQQ:
            if (state == ShareContentStateSuccess) {
                message = Locale(@"sm.shareto.qzone.success");
            } else {
                if (state == ShareContentStateUnInstalled) {
                    message = Locale(@"sm.shareto.qzone.notinstall");
                } else {
                    message = Locale(@"sm.shareto.qzone.fail");
                }
            }
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:Locale(@"sm.general.hint") message:message];
        [alertView bk_setCancelButtonWithTitle:Locale(@"sm.general.ok") handler:^{
            if (self.shareFinishBlock) {
                self.shareFinishBlock();
            }
        }];
        [alertView show];
    });
    
}

+ (BOOL)isAuthPlatform:(SMPlatform)platform
{
    switch (platform) {
        case SMPlatformTencentQQ:
            if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:TENCENTQQ_ACCESS_TOKEN]]) {
                return YES;
            }
            break;
        case SMPlatformWeixin:
            if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:WEIXIN_ACCESS_TOKEN]]) {
                return YES;
            }
            break;
//        case SMPlatformWeibo:
        case SMPlatformWeiboOAuth:
            if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:WEIBO_ACCESS_TOKEN]]) {
                return YES;
            }
            break;
//        case SMPlatformFacebook:
        case SMPlatformFacebookOAuth:
            if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:FACEBOOK_ACCESS_TOKEN]]) {
                return YES;
            }
            break;
        case SMPlatformTwitterOAuth:
            if ([[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:TWITTER_ACCESS_TOKEN prefix:nil]) {
                return YES;
            }
            break;
            
        default:
            break;
    }
    return NO;
}

+ (void)removeAuthWithPlatform:(SMPlatform)platform
{
    switch (platform) {
        case SMPlatformTencentQQ:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:TENCENTQQ_ACCESS_TOKEN];
            break;
        case SMPlatformWeixin:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:WEIXIN_ACCESS_TOKEN];
            break;
//        case SMPlatformWeibo:
        case SMPlatformWeiboOAuth:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:WEIBO_ACCESS_TOKEN];
            break;
//        case SMPlatformFacebook:
        case SMPlatformFacebookOAuth:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:FACEBOOK_ACCESS_TOKEN];
            break;
        case SMPlatformTwitterOAuth:
            [OAToken removeFromUserDefaultsWithServiceProviderName:TWITTER_ACCESS_TOKEN prefix:nil];
            break;
            
        default:
            break;
    }
}

+ (NSArray *)authPlatformList
{
    NSMutableArray *authList = [NSMutableArray array];
    for (id platform in ShareTagList) {
        switch ([platform integerValue]) {
            case SMPlatformTencentQQ:
                if ([ShareManager isAuthPlatform:SMPlatformTencentQQ]) {
                    [authList addObject:platform];
                }
                break;
            case SMPlatformWeixin:
                if ([ShareManager isAuthPlatform:SMPlatformWeixin]) {
                    [authList addObject:platform];
                }
                break;
//            case SMPlatformWeibo:
            case SMPlatformWeiboOAuth:
                if ([ShareManager isAuthPlatform:SMPlatformWeiboOAuth]) {
                    [authList addObject:platform];
                }
                break;
//            case SMPlatformFacebook:
            case SMPlatformFacebookOAuth:
                if ([ShareManager isAuthPlatform:SMPlatformFacebookOAuth]) {
                    [authList addObject:platform];
                }
                break;
            case SMPlatformTwitterOAuth:
                if ([ShareManager isAuthPlatform:SMPlatformTwitterOAuth]) {
                    [authList addObject:platform];
                }
                break;
                
            default:
                break;
        }
    }
    return [NSArray arrayWithArray:authList];
}

@end
