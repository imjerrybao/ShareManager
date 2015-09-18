# ShareManager
A SNS(Social Networking Services) Share Manager for ios, support Instagram, Facebook, Twitter, Weibo, QQ and Wechat.


Support single and batch share to social platforms.

# PreView
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s1.png" alt="Drawing" width="320px" />
<img src="https://raw.githubusercontent.com/imjerrybao/ShareManager/master/ReadmeImages/s2.png" alt="Drawing" width="320px" />

# How To Integrate to Your Project
1. System Requirement

    iOS 7 or later

2. Install via cocoapods

    ````
    pod 'ShareManager'
    ````

3. AppDelegate add below code
    ```` objective-c
    #import "ShareManager.h"

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.

        [self initSharePlatform];

        return YES;
    }

    - (void)initSharePlatform
    {
    #warning Replace the share platforms app key, secret and redirect uri to yours
    
        [[ShareManager sharedManager] initTencentQQWithAppKey:@"kQzoneKey" appSecret:@"kQzoneSecret"];
        [[ShareManager sharedManager] initWexinWithAppKey:@"kWeixinAppKey" appSecret:@"kWeixinAppSecret"];
        [[ShareManager sharedManager] initWeiboWithAppKey:@"kWeiboAppKey" appSecret:@"kWeiboSecret" redirectUri:@"kWeiboRedirectUri"];
        [[ShareManager sharedManager] initTwitterWithAppKey:@"kTwitterAppKey" appSecret:@"kTwitterAppSecret" redirectUri:@"kTwitterRedirectUri"];
        [[ShareManager sharedManager] initFacebookWithAppKey:@"kFacebookAppKey" appSecret:@"kFacebookAppSecret" redirectUri:@"kFacebookRedirectUri"];
        [[ShareManager sharedManager] initInstagram];
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

4. Add URL Schemes to Info.plist

    Reference to the example's Info.plist
    
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
    ````
# Handle Share Result
    use ShareManagerDelegate
    ````
    - (void)showShareResult:(SMShareResult *)result;
    ````
    Reference the demos ViewController.m file

# Issues
Any issues can email me: imjerrybao@gmail.com

# License
The MIT License (MIT)

Copyright (c) 2015 Jerry Bao

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

