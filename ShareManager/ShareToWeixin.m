//
//  ShareToWeixin.m
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareToWeixin.h"
#import "WXApi.h"
#import "WXApiObject.h"

@interface ShareToWeixin()
@property (nonatomic, strong) SMContent *content;
@end

@implementation ShareToWeixin

+ (ShareToWeixin *)sharedInstance
{
    static ShareToWeixin *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToWeixin alloc] init];
    });
    return sharedInstance;
}

- (void)initWeixinWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    _appKey = appKey;
    _appSecret = appSecret;
    [WXApi registerApp:_appKey];
}
-(BOOL) handleOpenURL:(NSURL *) url
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - 获取绑定授权
- (void)obtainAccessTokenWithCompletionBlock:(ObtainWeixinTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainWeixinTokenBlock)aFailedBlock
{
    [self setCompletionTokenBlock:aCompletionBlock];
    [self setFailedTokenBlock:aFailedBlock];
    
    [self sendAuthRequest];
}

#pragma mark - sdk方式分享
- (void) shareWithContent:(SMContent *)content
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareWeixinBlock)aCompletionBlock
                  failedBlock:(ShareWeixinBlock)aFailedBlock
{
    [self setFailedBlock:aFailedBlock];
    _content = content;
    
    if (![WXApi isWXAppInstalled]) {
        if(_failureBlock){
            _failureBlock(ShareContentStateUnInstalled);
        }
        _failureBlock = nil;
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = _content.title;
    message.description = _content.desc;
    [message setThumbImage:[self getWXThumbImage:_content.image.compressedImage]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = _content.url;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    [WXApi sendReq:req];
    
    
    //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if (sceneSession == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    [self setCompletionBlock:aCompletionBlock];
    
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{
    
}
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess) {
            if(_completionBlock){
                _completionBlock(ShareContentStateSuccess);
            }
        }else{
            if(_failureBlock){
                _failureBlock(ShareContentStateFail);
            }
        }
        
        _completionBlock = nil;
        _failureBlock = nil;
    }
    
    
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
//    SendAuthResp *aresp = (SendAuthResp *)resp;
//    if (aresp.errCode == 0) {
//        _code = aresp.code;
//    }
    
}

#pragma mark - WeiChat API
/*
 * @param image 缩略图
 * @note 大小不能超过32K
 */
- (UIImage *)getWXThumbImage:(UIImage *)image
{
    CGFloat  size  = (image.size.width*image.size.height)/1024;
    CGFloat  scaleSize = (size<32)?1.0:(32/size);
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - Set ReqBlock
- (void)setCompletionBlock:(ShareWeixinBlock)aCompletionBlock{
    _completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(ShareWeixinBlock)aFailedBlock{
    _failureBlock = [aFailedBlock copy];
}

- (void)setCompletionTokenBlock:(ObtainWeixinTokenBlock)aCompletionBlock {
    _completionTokenBlock = [aCompletionBlock copy];
}
- (void)setFailedTokenBlock:(ObtainWeixinTokenBlock)aFailedBlock {
    _failureTokenBlock = [aFailedBlock copy];
}



#pragma mark - auth action
- (void)sendAuthRequest
{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    [WXApi sendReq:req];
}

- (void)getAccessToken
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", _appKey, _appSecret, _code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                
                _accessToken = [dic objectForKey:@"access_token"];
                _openId = [dic objectForKey:@"openid"];
                NSLog(@"access_token: %@", _accessToken);
                NSLog(@"openid: %@", _openId);
                
            }
        });
    });
}

- (void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", _accessToken, _openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                NSLog(@"nickname: %@", [dic objectForKey:@"nickname"]);
                NSLog(@"headimgurl: %@", [dic objectForKey:@"headimgurl"]);
            }
        });
        
    });
}

@end
