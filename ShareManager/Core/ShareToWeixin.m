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
#if !TARGET_IPHONE_SIMULATOR
    [WXApi registerApp:_appKey];
#endif
}
-(BOOL) handleOpenURL:(NSURL *) url
{
#if !TARGET_IPHONE_SIMULATOR
    return [WXApi handleOpenURL:url delegate:self];
#endif
    return NO;
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
    
#if !TARGET_IPHONE_SIMULATOR
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
#endif
}

#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{
    
}
-(void) onResp:(BaseResp*)resp
{
#if !TARGET_IPHONE_SIMULATOR
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
#endif
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
#if !TARGET_IPHONE_SIMULATOR
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    [WXApi sendReq:req];
#endif
}


@end
