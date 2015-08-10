# ShareManagerDemo
# A SNS Platform Share Manager for ios, support Facebook, Twitter, Weixin, QQ and Weixin.

# 使用方法：
pod install ShareManager

# AppDelegate中添加添加一些代码

\#import "ShareManager.h"

\- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self initSharePlatform];

    return YES;
}

\- (void)initSharePlatform
{
    [[ShareManager sharedManager] initTencentQQWithAppKey:kQzoneKey appSecret:kQzoneSecret];
    [[ShareManager sharedManager] initWexinWithAppKey:kWeixinAppKey appSecret:kWeixinAppSecret];
    [[ShareManager sharedManager] initWeiboWithAppKey:kWeiboAppKey appSecret:kWeiboSecret redirectUri:kWeiboRedirectUri];
    [[ShareManager sharedManager] initTwitterWithAppKey:kTwitterAppKey appSecret:kTwitterAppSecret redirectUri:kTwitterRedirectUri];
    [[ShareManager sharedManager] initFacebookWithAppKey:kFacebookAppKey appSecret:kFacebookAppSecret redirectUri:kFacebookRedirectUri];
}

\- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [[ShareManager sharedManager] handleOpenURL:url];
}

\- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[ShareManager sharedManager] handleOpenURL:url];
}

# Info.plist中添加微信和qq的URL Scheme
参考本例子