//
//  SMWebViewController.m
//  ShareManager
//
//  Created by Jerry on 12/25/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "SMWebViewController.h"
#import "SMConstant.h"

@interface SMWebViewController()
@property (nonatomic, strong) UIColor *originNavBarColor;
@end

@implementation SMWebViewController

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _titleText = title;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    _headerView = headerView;
    _headerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_headerView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, 30, 100, 30)];
    _titleLbl = titleLbl;
    _titleLbl.textAlignment = NSTextAlignmentCenter;
    _titleLbl.textColor = [UIColor whiteColor];
    _titleLbl.font = [UIFont systemFontOfSize:17];
    _titleLbl.text = _titleText;
    [_headerView addSubview:_titleLbl];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(10, 20, 44, 44);
    [closeBtn setImage:LoadImage(@"icon_closew")] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:closeBtn];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _headerView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-_headerView.height)];
    _webView = webView;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dismiss
{
    if([self.delegate respondsToSelector:@selector(SMWebClose)])
    {
        [self.webDelegate SMWebClose];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopLoading
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
