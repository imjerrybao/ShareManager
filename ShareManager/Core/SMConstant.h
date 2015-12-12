//
//  Constant.h
//  ShareManager
//
//  Created by Jerry on 12/23/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#ifndef ShareManager_SMConstant_h
#define ShareManager_SMConstant_h
#import <MBProgressHUD/MBProgressHUD.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import "NSString+util.h"
#import "UIView+size.h"
#import "UIColor+hex.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define Locale(str)  NSLocalizedStringFromTableInBundle(str, @"Root", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SMResources.bundle"]], nil)
#define LoadImage(img)  [UIImage imageNamed:[NSString stringWithFormat:@"SMResources.bundle/images/%@", img]

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

typedef NS_ENUM(NSInteger, SMPlatform) {
    SMPlatformTencentQQ = 1,
    SMPlatformWeixin,
//    SMPlatformWeibo,
    SMPlatformWeiboOAuth,
//    SMPlatformFacebook,
    SMPlatformFacebookOAuth,
    SMPlatformTwitterOAuth,
    SMPlatformInstagram,
};