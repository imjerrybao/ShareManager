//
//  ViewController.m
//  ShareManagerDemo
//
//  Created by Jerry on 8/5/15.
//  Copyright (c) 2015 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "ShareManager.h"
#import "SMConfig.h"

@interface ViewController ()
@property (nonatomic, strong) NSString *sTitle;
@property (nonatomic, strong) NSString *sDesc;
@property (nonatomic, strong) NSString *sContent;
@property (nonatomic, strong) NSString *sUrl;
@property (nonatomic, strong) SMImage *sImage;
@property (nonatomic, strong) NSMutableArray *shareList;
@property (nonatomic) BOOL enableFacebook, enableTwitter, enableWeibo, enableWeixin, enableQQ;

@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *qzoneBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sTitle = @"这是qq和微信的标题"; //只对qq和微信有效
    _sDesc = @"这是内容";
    _sUrl = @"http://www.baidu.com";
    _sImage = [[SMImage alloc] initWithImageUrl:@"https://www.baidu.com/img/bdlogo.png"];
    _shareList = [NSMutableArray array];
    
    _facebookBtn.tag = 1000+SMPlatformFacebookOAuth;
    _twitterBtn.tag = 1000+SMPlatformTwitterOAuth;
    _weiboBtn.tag = 1000+SMPlatformWeiboOAuth;
    _weixinBtn.tag = 1000+SMPlatformWeixin;
    _qzoneBtn.tag = 1000+SMPlatformTencentQQ;
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

@end
