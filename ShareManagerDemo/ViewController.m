//
//  ViewController.m
//  ShareManagerDemo
//
//  Created by Jerry on 8/5/15.
//  Copyright (c) 2015 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "ShareManager.h"
#import "SMConstant.h"

@interface ViewController () <ShareManagerDelegate>
@property (nonatomic, strong) NSString *sTitle;
@property (nonatomic, strong) NSString *sDesc;
@property (nonatomic, strong) NSString *sContent;
@property (nonatomic, strong) NSString *sUrl;
@property (nonatomic, strong) SMImage *sImage;
@property (nonatomic, strong) NSMutableArray *shareList;
@property (nonatomic) BOOL enableFacebook, enableTwitter, enableWeibo, enableWeixin, enableQQ, enableInstagram;

@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *qzoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *instagramBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sTitle = @"Your QQ or Weixin share title"; //Only support QQ and Weixin
    _sDesc = @"Your share content";
    _sUrl = @"http://www.facebook.com";
    _sImage = [[SMImage alloc] initWithImageUrl:@"http://e.hiphotos.baidu.com/image/w%3D310/sign=af410cc1f536afc30e0c39648319eb85/6f061d950a7b0208d7fa7ee060d9f2d3572cc884.jpg"];
    _shareList = [NSMutableArray array];
    
    _facebookBtn.tag = 1000+SMPlatformFacebookOAuth;
    _twitterBtn.tag = 1000+SMPlatformTwitterOAuth;
    _weiboBtn.tag = 1000+SMPlatformWeiboOAuth;
    _weixinBtn.tag = 1000+SMPlatformWeixin;
    _qzoneBtn.tag = 1000+SMPlatformTencentQQ;
    _instagramBtn.tag = 1000+SMPlatformInstagram;
    
    [ShareManager sharedManager].shareDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareWithSingle:(id)sender {
    [[ShareManager sharedManager] setContentWithTitle:_sTitle description:_sDesc image:_sImage url:_sUrl];
    [[ShareManager sharedManager] showShareWindow];
}

- (IBAction)enablePlatForm:(id)sender {
    NSInteger tag = ((UIView*)sender).tag;
    switch (tag-1000) {
        case SMPlatformFacebookOAuth:
        {
            if (!_enableFacebook) {
                [[ShareManager sharedManager] obtainAccessTokenWithPlatform:SMPlatformFacebookOAuth successBlock:^{
                    [_facebookBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/facebook2"] forState:UIControlStateNormal];
                    _enableFacebook = !_enableFacebook;
                    [_shareList addObject:@(SMPlatformFacebookOAuth)];
                } failBlock:^{
                    
                }];
            } else {
                [_facebookBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/facebook1"] forState:UIControlStateNormal];
                _enableFacebook = !_enableFacebook;
                [_shareList removeObject:@(SMPlatformFacebookOAuth)];
            }
        }
            break;
        case SMPlatformTwitterOAuth:
        {
            if (!_enableTwitter) {
                [[ShareManager sharedManager] obtainAccessTokenWithPlatform:SMPlatformTwitterOAuth successBlock:^{
                    [_twitterBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/twitter2"] forState:UIControlStateNormal];
                    _enableTwitter = !_enableTwitter;
                    [_shareList addObject:@(SMPlatformTwitterOAuth)];
                } failBlock:^{
                    
                }];
            } else {
                [_twitterBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/twitter1"] forState:UIControlStateNormal];
                _enableTwitter = !_enableTwitter;
                [_shareList removeObject:@(SMPlatformTwitterOAuth)];
            }
        }
            break;
        case SMPlatformWeiboOAuth:
        {
            
            if (!_enableWeibo) {
                [[ShareManager sharedManager] obtainAccessTokenWithPlatform:SMPlatformWeiboOAuth successBlock:^{
                    [_weiboBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/weibo2"] forState:UIControlStateNormal];
                    _enableWeibo = !_enableWeibo;
                    [_shareList addObject:@(SMPlatformWeiboOAuth)];
                } failBlock:^{
                    
                }];
            } else {
                [_weiboBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/weibo1"] forState:UIControlStateNormal];
                _enableWeibo = !_enableWeibo;
                [_shareList removeObject:@(SMPlatformWeiboOAuth)];
            }
        }
            break;
        case SMPlatformWeixin:
        {
            if (!_enableWeixin) {
                [_weixinBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/weixin2"] forState:UIControlStateNormal];
                [_shareList addObject:@(SMPlatformWeixin)];
            } else {
                [_weixinBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/weixin1"] forState:UIControlStateNormal];
                [_shareList removeObject:@(SMPlatformWeixin)];
            }
            _enableWeixin = !_enableWeixin;
        }
            break;
        case SMPlatformTencentQQ:
        {
            if (!_enableQQ) {
                [_qzoneBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/qzone2"] forState:UIControlStateNormal];
                [_shareList addObject:@(SMPlatformTencentQQ)];
            } else {
                [_qzoneBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/qzone1"] forState:UIControlStateNormal];
                [_shareList removeObject:@(SMPlatformTencentQQ)];
            }
            _enableQQ = !_enableQQ;
        }
            break;
        case SMPlatformInstagram:
        {
            if (!_enableInstagram) {
                [_instagramBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/instagram2"] forState:UIControlStateNormal];
                [_shareList addObject:@(SMPlatformInstagram)];
            } else {
                [_instagramBtn setImage:[UIImage imageNamed:@"SMResources.bundle/images/instagram1"] forState:UIControlStateNormal];
                [_shareList removeObject:@(SMPlatformInstagram)];
            }
            _enableInstagram = !_enableInstagram;
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)shareWithBatch:(id)sender {
    if (_shareList.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Locale(@"sm.general.hint") message:Locale(@"sm.select.platform") delegate:nil cancelButtonTitle:Locale(@"sm.general.ok") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [[ShareManager sharedManager] setContentWithTitle:_sTitle description:_sDesc image:_sImage url:_sUrl];
    [[ShareManager sharedManager] batchShareWithShareList:_shareList];
}

#pragma mark - ShareManagerDelegate
- (void)showShareResult:(SMShareResult *)result
{
    SMPlatform platform = result.platform;
    ShareContentState state = result.state;
    
    NSString *message;
    switch (platform) {
        case SMPlatformFacebookOAuth:
            if (state == ShareContentStateSuccess) {
                message = @"(custom string) facebook share success";
            } else {
                message = @"(custom string) facebook share fail";
            }
            break;
        case SMPlatformTwitterOAuth:
            if (state == ShareContentStateSuccess) {
                message = @"(custom string) twitter share success";
            } else {
                message = @"(custom string) twitter share fail";
            }
            break;
        case SMPlatformWeiboOAuth:
            if (state == ShareContentStateSuccess) {
                message = @"(custom string) weibo share success";
            } else {
                message = @"(custom string) weibo share fail";
            }
            break;
        case SMPlatformWeixin:
            if (state == ShareContentStateSuccess) {
                message = @"(custom string) weixin.success";
            } else {
                if (state == ShareContentStateUnInstalled) {
                    message = @"(custom string) weixin not install";
                } else {
                    message = @"(custom string) weixin share fail";
                }
            }
            break;
        case SMPlatformTencentQQ:
            if (state == ShareContentStateSuccess) {
                message = @"(custom string) qzone success";
            } else {
                if (state == ShareContentStateUnInstalled) {
                    message = @"(custom string) qzone not install";
                } else {
                    message = @"(custom string) qzone share fail";
                }
            }
            break;
        default:
            break;
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:message delegate:nil cancelButtonTitle:@"Got it" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
