# ShareManager
A SNS Platform Share Manager for ios, support Facebook, Twitter, QQ and Weixin.

# PreView
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s1.jpg" alt="Drawing" width="300px" />
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s2.jpg" alt="Drawing" width="300px" />

# How To Integrate to Your Project
1. Install via pod

    ````
    platform :ios, '7.0'
    
    target 'Your_Target' do
    
    pod 'ShareManager', :git => 'https://github.com/imjerrybao/ShareManager.git'
    
    end
    ````

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
    # Replace the share platforms app key, secret and redirect uri to yours
    
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

