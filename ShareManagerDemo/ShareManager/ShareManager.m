//
//  AppDelegate.h
//  ShareManager
//
//  Created by Jerry on 12/17/14.
//  Copyright (c) 2014 __CompanyName__ All rights reserved.
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
    DLOG(@"handleOpenURL: %@",url.absoluteString);
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
    //weibo
    r = [url.absoluteString rangeOfString:_weiboAppKey];
    if (r.location != NSNotFound) {
        return [[ShareToWeibo sharedInstance] handleOpenURL:url];
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
                  mediaType:(SMMediaType)mediaType
//             personalRecord:(PersonalRecord *)personalRecord
{
    SMContent *content = [[SMContent alloc] init];
    content.title = title;
    content.desc = description;
    content.image = image;
    content.url = url;
    content.mediaType = mediaType;
//    content.personalRecord = personalRecord;
    _shareContent = content;
}

- (void)setContentWithTitle:(NSString *)title
                description:(NSString*)description
                    imageId:(NSString *)imageId
                        url:(NSString *)url
                  mediaType:(SMMediaType)mediaType
//             personalRecord:(PersonalRecord *)personalRecord
                       view:(UIView *)view
{
    SMContent *content = [[SMContent alloc] init];
    content.title = title;
    content.desc = description;
    content.url = url;
    content.imageId = imageId;
    content.mediaType = mediaType;
//    content.personalRecord = personalRecord;
    content.view = view;
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
        DLOG(@"没有填写分享内容，先调用setShareContent设置");
        return;
    }
    if (_shareContent.imageId)
    {
//        if(platform == SMPlatformTencentQQ || platform == SMPlatformWeiboOAuth || platform == SMPlatformTwitterOAuth)
//        {
//            [MBProgressHUD showHUDAddedTo:_shareContent.view animated:YES];
//        }
//        [_shareContent.personalRecord singleSync:^(id responseObject) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                PersonalRecord *p = [[PersonalRecord selectByProperty:@"id" propertyValue:[responseObject objectForKey:@"id"]] lastObject];
//                PersonalRecordBase *pBase = [PersonalRecord personalRecordBase:p];
//                UIImage *image = [[APIClient sharedInstance] getCachedImageById:[pBase.image lastObject]];
//                image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.3)];
//                SMImage *smImage = [[SMImage alloc] initWithImage:image];
//                _shareContent.image = smImage;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self share:platform successBlock:successBlock failBlock:failBlock];
//                });
//            });
//        } fHandler:^(NSError *error) {
//            [MBProgressHUD hideHUDForView:_shareContent.view animated:YES];
//        }];
//        [MBProgressHUD showHUDAddedTo:_shareContent.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_shareContent.view animated:YES];
        [hud show:YES];
        [[APIClient sharedInstance] getImageWithId:_shareContent.imageId success:^(NSString *imageId, UIImage *image) {
            [hud hide:YES];
            SMImage *smImage = [[SMImage alloc] initWithImage:image];
            _shareContent.image = smImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self share:platform successBlock:successBlock failBlock:failBlock];
            });
        } failure:^(NSError *error) {
            [hud hide:YES];
        }];
    }
    else
    {
        [self share:platform successBlock:successBlock failBlock:failBlock];
    }
    
}

//名字没想好,就这样
- (void)share:(SMPlatform)platform
                  successBlock:(ShareManagerBlock)successBlock
                     failBlock:(ShareManagerBlock)failBlock
{
    if (_shareContent.mediaType == SMMediaTypeNews) {
        switch (platform) {
            case SMPlatformTencentQQ:
            {
                [[ShareToTencentQQ sharedInstance] shareNewsWithContent:_shareContent
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
                NSString *message = @"微信分享需应用上架后审核，该功能将在下一版提供支持";
                if ([[GlobalConfig useLanguage] isEqualToString:@"zh-Hant"]) {
                    message = @"微信分享需應用上架後審核，該功能將在下一版提供支持";
                } else if ([[GlobalConfig useLanguage] isEqualToString:@"en"]) {
                    message = @"WeChat Share will be available in the next version!";
                }
                UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:Locale(@"sm.general.hint") message:message];
                [alert bk_setCancelButtonWithTitle:Locale(@"sm.general.ok") handler:^{
                    if (self.shareFinishBlock) {
                        self.shareFinishBlock();
                    }
                }];
                [alert show];
                return;
                [[ShareToWeixin sharedInstance] shareNewsWithContent:_shareContent
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
            {
                [[ShareToWeibo sharedInstance] shareNewsWithContent:_shareContent
                                                    completionBlock:^(ShareContentState resultCode) {
                                                        
                                                        if (successBlock) {
                                                            successBlock(resultCode);
                                                        }
                                                        [self showShareResultWithPlatform:SMPlatformWeibo state:ShareContentStateSuccess];
                                                        
                                                    } failedBlock:^(ShareContentState resultCode) {
                                                        
                                                        if (failBlock) {
                                                            failBlock(resultCode);
                                                        }
                                                        [self showShareResultWithPlatform:SMPlatformWeibo state:ShareContentStateFail];
                                                    }];
                
            }
                break;
            case SMPlatformWeiboOAuth:
            {
                [[ShareToWeibo sharedInstance] shareOAuthNewsWithContent:_shareContent
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
            {
                [[ShareToFacebook sharedInstance] shareNewsWithContent:_shareContent
                                                       completionBlock:^(ShareContentState resultCode) {
                                                           
                                                           if (successBlock) {
                                                               successBlock(resultCode);
                                                           }
                                                           [self showShareResultWithPlatform:SMPlatformFacebook state:ShareContentStateSuccess];
                                                           
                                                       } failedBlock:^(ShareContentState resultCode) {
                                                           
                                                           if (failBlock) {
                                                               failBlock(resultCode);
                                                           }
                                                           [self showShareResultWithPlatform:SMPlatformFacebook state:ShareContentStateFail];
                                                       }];
            }
                break;
            case SMPlatformFacebookOAuth:
            {
                NSString *message = @"目前版本暂不支持分享到Facebook";
                if ([[GlobalConfig useLanguage] isEqualToString:@"zh-Hant"]) {
                    message = @"目前版本暫不支持分享到Facebook";
                } else if ([[GlobalConfig useLanguage] isEqualToString:@"en"]) {
                    message = @"Unable to share on Facebook temporarily!";
                }
                UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:Locale(@"sm.general.hint") message:message];
                [alert bk_setCancelButtonWithTitle:Locale(@"sm.general.ok") handler:^{
                    if (self.shareFinishBlock) {
                        self.shareFinishBlock();
                    }
                }];
                [alert show];
                return;
                [[ShareToFacebook sharedInstance] shareOAuthNewsWithContent:_shareContent
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
                [[ShareToTwitter sharedInstance] shareOAuthNewsWithContent:_shareContent
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
            case SMPlatformAngler:
            {
//                [[APIClient sharedInstance] shareToAngler:_shareContent.personalRecord needToUploadImages:_shareContent.personalRecord.image sHandler:^(id responseObject) {
//                    
//                    if (successBlock) {
//                        successBlock(ShareContentStateSuccess);
//                    }
//                    [self showShareResultWithPlatform:SMPlatformAngler state:ShareContentStateSuccess];
//                    
//                } fHandler:^(NSError *error) {
//                    failBlock(ShareContentStateFail);
//                    [self showShareResultWithPlatform:SMPlatformAngler state:ShareContentStateFail];
//                }];
//            }
            }
                break;
            default:
                break;
        }
        return;
    }
}

#pragma mark - 一键分享actions
- (void)obtainAccessTokenWithPlatform:(SMPlatform)platform
                         successBlock:(void(^)(void))successBlock
                            failBlock:(void(^)(void))failBlock
{
    switch (platform) {
        case SMPlatformFacebookOAuth:
        {
            [[ShareToFacebook sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                                                 DLOG(@"obtain access token success");
                                                 if (successBlock) {
                                                     successBlock();
                                                 }
                                             } failedBlock:^ {
                                                 DLOG(@"obtain access token fail");
                                                 if (failBlock) {
                                                     failBlock();
                                                 }
                                             }];
        }
            break;
        case SMPlatformTwitterOAuth:
        {
            [[ShareToTwitter sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                
                                                   DLOG(@"obtain access token success");
                                                   if (successBlock) {
                                                       successBlock();
                                                   }
                                                } failedBlock:^ {
                                                    
                                                    DLOG(@"obtain access token fail");
                                                    if (failBlock) {
                                                        failBlock();
                                                    }
                                                }];
            
        }
            break;
        case SMPlatformWeiboOAuth:
        {
            [[ShareToWeibo sharedInstance] obtainAccessTokenWithCompletionBlock:^ {
                                                 DLOG(@"obtain access token success");
                                                 if (successBlock) {
                                                     successBlock();
                                                 }
                                             } failedBlock:^ {
                                                 DLOG(@"obtain access token fail");
                                                 if (failBlock) {
                                                     failBlock();
                                                 }
                                             }];
        }
            break;
        case SMPlatformTencentQQ:
        {
            [[ShareToTencentQQ sharedInstance] obtainAccessTokenWithCompletionBlock:^{
                DLOG(@"obtain access token success");
                if (successBlock) {
                    successBlock();
                }
            } failedBlock:^{
                DLOG(@"obtain access token fail");
                if (failBlock) {
                    failBlock();
                }
            }];
        }
            break;
        case SMPlatformWeixin:
        {
            [[ShareToWeixin sharedInstance] obtainAccessTokenWithCompletionBlock:^{
                DLOG(@"obtain access token success");
                if (successBlock) {
                    successBlock();
                }
            } failedBlock:^{
                DLOG(@"obtain access token fail");
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
        case SMPlatformAngler:
            if (state == ShareContentStateSuccess) {
                title = Locale(@"sm.shareto.angler.success");
            } else {
                title = Locale(@"sm.shareto.angler.fail");
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
