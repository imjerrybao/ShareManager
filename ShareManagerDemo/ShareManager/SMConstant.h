//
//  Constant.h
//  ShareManager
//
//  Created by Jerry on 12/23/14.
//  Copyright (c) 2014 __CompanyName__ All rights reserved.
//

#ifndef ShareManager_SMConstant_h
#define ShareManager_SMConstant_h

// Sina Weibo
#define kWeiboAppKey                   @"4232278277"
#define kWeiboSecret                   @"a37459c32cf7c284ea9512eeea223b17"
#define kWeiboRedirectUri              @"http://share.solot.com"

// Facebook
#define KFacebookAppKey                @"1497868057149835"
#define kFacebookAppSecret             @"1ea0b49f2a71536084393814a48f6a34"
#define kFacebookRedirectUri           @"http://www.angler.im/"

// Twitter
#define kTwitterAppKey                 @"LTiFoqmygc59hjr2iEIOUw1Du"
#define kTwitterAppSecret              @"bbIkmbh90Y8jccY0LU4gwt8MR8n0bYVutyFSXS6dNm3vOKGWJI"
#define kTwitterRedirectUri            @"http://www.angler.im/"

// Weixin
#define kWeixinAppKey                  @"wx7d3e05efd366c921"
#define KWeixinAppSecret               @"ee4d6433fd32308248ed00f131945bc9"

// Qzone
#define KQzoneKey                      @"1104553988"
#define KQzoneSecret                   @"eBar7wH3TQwnFIje"


/**
 *	@brief	发布内容状态
 */
typedef enum{
    ShareContentStateBegan = 0,              /**< 开始 */
    ShareContentStateSuccess = 1,            /**< 成功 */
    ShareContentStateFail = 2,               /**< 失败 */
    ShareContentStateUnInstalled = 3,        /**< 未安装 */
    ShareContentStateCancel = 4,             /**< 取消 */
    ShareContentStateNotSupport = 5          /**< 设备不支持 */
}ShareContentState;
#endif

typedef NS_ENUM(NSInteger, SMMediaType) {
    SMMediaTypeNews = 1, //新闻，目前只支持此类型
    SMMediaTypeText,     //文本
    SMMediaTypeImage,    //图片
};

typedef NS_ENUM(NSInteger, SMPlatform) {
    SMPlatformTencentQQ = 1,
    SMPlatformWeixin,
    SMPlatformWeibo,
    SMPlatformWeiboOAuth,
    SMPlatformFacebook,
    SMPlatformFacebookOAuth,
    SMPlatformTwitterOAuth,
    SMPlatformAngler,
};