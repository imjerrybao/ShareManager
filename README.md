# ShareManagerDemo
A SNS Platform Share Manager for ios, support Facebook, Twitter, Weixin, QQ and Weixin.

# How To Integrate to Your Project
1. Install via pod
pod install ShareManager

2. AppDelegate add below code
    ```` objective-c
    #import "ShareManager.h"

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.

        [self initSharePlatform];

        return YES;
    }

    - (void)initSharePlatform
    {
        [[ShareManager sharedManager] initTencentQQWithAppKey:kQzoneKey appSecret:kQzoneSecret];
        [[ShareManager sharedManager] initWexinWithAppKey:kWeixinAppKey appSecret:kWeixinAppSecret];
        [[ShareManager sharedManager] initWeiboWithAppKey:kWeiboAppKey appSecret:kWeiboSecret redirectUri:kWeiboRedirectUri];
        [[ShareManager sharedManager] initTwitterWithAppKey:kTwitterAppKey appSecret:kTwitterAppSecret redirectUri:kTwitterRedirectUri];
        [[ShareManager sharedManager] initFacebookWithAppKey:kFacebookAppKey appSecret:kFacebookAppSecret redirectUri:kFacebookRedirectUri];
    }

    - (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
    {
        return [[ShareManager sharedManager] handleOpenURL:url];
    }

    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return [[ShareManager sharedManager] handleOpenURL:url];
    }
    ````

3. add URL Schemes to Info.plist

    Reference to the example

4. Replace the share platforms app key, secret, redirect uri to yours in file SMConfig.m