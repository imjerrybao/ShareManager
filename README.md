# ShareManager
A SNS Platform Share Manager for ios, support Facebook, Twitter, QQ and Weixin.


Support single and batch share to social platforms.

# PreView
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s1.jpg" alt="Drawing" width="320px" />
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s2.jpg" alt="Drawing" width="320px" />

# How To Integrate to Your Project
1. Install via cocoapods

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
    
# Usage
1. Single Share
    ```` objective-c
    NSString *sTitle = @"Your QQ or Weixin share title"; //Only support QQ and Weixin 
    NSString *sDesc = @"Your share content";
    NSString *sUrl = @"http://www.facebook.com";
    SMImage *sImage = [[SMImage alloc] initWithImageUrl:@"http://e.hiphotos.baidu.com/image/w%3D310/sign=af410cc1f536afc30e0c39648319eb85/6f061d950a7b0208d7fa7ee060d9f2d3572cc884.jpg"];
    
    [[ShareManager sharedManager] setContentWithTitle:sTitle description:sDesc image:sImage url:sUrl];
    [[ShareManager sharedManager] showShareWindow];
    ````
2. Batch Share
    ```` objective-c
    NSString *sTitle = @"Your QQ or Weixin share title"; //Only support QQ and Weixin 
    NSString *sDesc = @"Your share content";
    NSString *sUrl = @"http://www.facebook.com";
    SMImage *sImage = [[SMImage alloc] initWithImageUrl:@"http://e.hiphotos.baidu.com/image/w%3D310/sign=af410cc1f536afc30e0c39648319eb85/6f061d950a7b0208d7fa7ee060d9f2d3572cc884.jpg"];
    NSMutableArray *shareList = [NSMutableArray arrayWithArray:@[@(SMPlatformWeiboOAuth), @(SMPlatformTencentQQ), @(SMPlatformWeixin), @(SMPlatformFacebookOAuth), @(SMPlatformTwitterOAuth)]];
    
    [[ShareManager sharedManager] setContentWithTitle:sTitle description:sDesc image:sImage url:sUrl];
    [[ShareManager sharedManager] batchShareWithShareList:shareList];

