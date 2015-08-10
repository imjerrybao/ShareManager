//
//  ShareToTencentQQ.m
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareToTencentQQ.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface ShareToTencentQQ()
@property (nonatomic, strong) SMContent *content;
@end

@implementation ShareToTencentQQ

+ (ShareToTencentQQ *)sharedInstance
{
    static ShareToTencentQQ *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToTencentQQ alloc] init];
    });
    return sharedInstance;
}
- (void)initTencentQQWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    _appKey = appKey;
    _appSecret = appSecret;
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:_appKey andDelegate:self];
}
- (BOOL)handleOpenURL:(NSURL *) url
{
    return [TencentOAuth HandleOpenURL:url];
}

#pragma mark - 获取绑定授权
- (void)obtainAccessTokenWithCompletionBlock:(ObtainQQTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainQQTokenBlock)aFailedBlock
{
    [self setCompletionTokenBlock:aCompletionBlock];
    [self setFailedTokenBlock:aFailedBlock];
    
    //NSArray *_permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    NSArray *_permissions = [NSArray arrayWithObjects:@"get_user_info", @"add_share", nil];
    [_tencentOAuth authorize:_permissions inSafari:NO]; //授权
}


#pragma mark - sdk方式分享
- (void)shareWithContent:(SMContent *)content
             completionBlock:(ShareQQBlock)aCompletionBlock
                 failedBlock:(ShareQQBlock)aFailedBlock
{
    [self setCompletionBlock:aCompletionBlock];
    [self setFailedBlock:aFailedBlock];
    
    _content = content;
    
    NSData* data = _content.image.compressedData;
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:_content.url]
                                title:_content.title
                                description:_content.desc
                                previewImageData:data];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    //将内容分享到qq
    //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将内容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleQQSendResult:sent];
}

- (void)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:{
            if (_completionBlock) {
                _completionBlock(ShareContentStateSuccess);
            }
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            if (_failureBlock) {
                _failureBlock(ShareContentStateUnInstalled);
            }
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPISENDFAILD:
        {
            if (_failureBlock) {
                _failureBlock(ShareContentStateFail);
            }
            
            break;
        }
        default:
        {
            if (_failureBlock) {
                _failureBlock(ShareContentStateFail);
            }
            break;
        }
    }
    _completionBlock = nil;
    _failureBlock = nil;
    
}

#pragma mark - Set ReqBlock
- (void)setCompletionBlock:(ShareQQBlock)aCompletionBlock{
    _completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(ShareQQBlock)aFailedBlock{
    _failureBlock = [aFailedBlock copy];
}

- (void)setCompletionTokenBlock:(ObtainQQTokenBlock)aCompletionBlock {
    _completionTokenBlock = [aCompletionBlock copy];
}
- (void)setFailedTokenBlock:(ObtainQQTokenBlock)aFailedBlock {
    _failureTokenBlock = [aFailedBlock copy];
}

#pragma mark TencentLoginDelegate
- (void)tencentDidLogin
{
    NSLog(@"qq登录完成");
    
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
        //  记录登录用户的OpenID、Token以及过期时间
        NSLog(@"token, %@", _tencentOAuth.accessToken);
        [[NSUserDefaults standardUserDefaults] setValue:_tencentOAuth.accessToken forKey:TENCENTQQ_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (_completionTokenBlock) {
            _completionTokenBlock();
        }
        _completionTokenBlock = nil;
        _failureTokenBlock = nil;
        
    }else{
        NSLog(@"登录不成功 没有获取accesstoken");
        if (_failureTokenBlock) {
            _failureTokenBlock();
        }
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        NSLog(@"用户取消登录");
    }else{
        NSLog(@"登录失败");
    }
}

-(void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络");
}

- (void)tencentDidLogout
{
}

@end
