//
//  AppDelegate.h
//  ShareManager
//
//  Created by Jerry on 12/17/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareManager.h"

#define ShareImageList    @[@"sns_weibo", @"sns_qzone", @"sns_weixin", @"sns_facebook", @"sns_twitter"]
#define ShareTitleList    @[Locale(@"sm.weibo"), Locale(@"sm.qzone"), Locale(@"sm.weixin"), Locale(@"sm.facebook"), Locale(@"sm.twitter")]
#define ShareTagList      @[@(SMPlatformWeiboOAuth), @(SMPlatformTencentQQ), @(SMPlatformWeixin), @(SMPlatformFacebookOAuth), @(SMPlatformTwitterOAuth)]

@interface ShareManager ()
@property (nonatomic, assign) int index;

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

- (void)setPresentViewController:(UIViewController *)presentViewController
{
    _presentViewController = presentViewController;
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

-(BOOL) handleOpenURL:(NSURL *) url
{
    NSLog(@"handleOpenURL: %@",url.absoluteString);
    //tencentQQ
    NSRange r = [url.absoluteString rangeOfString:_tencentQQAppKey];
    if (r.location != NSNotFound) {
        return [[ShareToTencentQQ sharedInstance] handleOpenURL:url];
    }
    //weixin
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
    [[ShareUI sharedInstance] showShareWindowWithImageList:ShareImageList titleList:ShareTitleList tagList:ShareTagList];
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
        case SMPlatformWeibo:
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
        case SMPlatformFacebook:
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
        case SMPlatformFacebook:
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
        case SMPlatformWeibo:
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
    
    NSString *title;
    switch (platform) {
        case SMPlatformFacebookOAuth:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.facebook.success");
            } else {
                title = Locale(@"sm.shareto.facebook.fail");
            }
            break;
        case SMPlatformTwitterOAuth:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.twitter.success");
            } else {
                title = Locale(@"sm.shareto.twitter.fail");
            }
            break;
        case SMPlatformWeiboOAuth:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.weibo.success");
            } else {
                title = Locale(@"sm.shareto.weibo.fail");
            }
            break;
        case SMPlatformWeixin:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.weixin.success");
            } else {
                if (state == ShareContentStateUnInstalled) {
                    title = Locale(@"sm.shareto.weixin.notinstall");
                } else {
                    title = Locale(@"sm.shareto.weixin.fail");
                }
            }
            break;
        case SMPlatformTencentQQ:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.qzone.success");
            } else {
                if (state == ShareContentStateUnInstalled) {
                    title = Locale(@"sm.shareto.qzone.notinstall");
                } else {
                    title = Locale(@"sm.shareto.qzone.fail");
                }
            }
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Locale(@"sm.general.hint") message:title delegate:nil cancelButtonTitle:Locale(@"sm.general.ok") otherButtonTitles:nil, nil];
        
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:Locale(@"sm.general.hint") message:title];
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
        case SMPlatformWeibo:
        case SMPlatformWeiboOAuth:
            if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:WEIBO_ACCESS_TOKEN]]) {
                return YES;
            }
            break;
        case SMPlatformFacebook:
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

@end
