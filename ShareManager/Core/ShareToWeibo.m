//
//  ShareToWeibo.m
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareToWeibo.h"
#import "OAuthConsumer.h"
#import "ShareManager.h"

@interface ShareToWeibo() <UIWebViewDelegate, SMWebViewControllerDelegate>
@property (nonatomic, strong) SMWebViewController *webViewController;
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) SMContent *content;
@end;

@implementation ShareToWeibo

+ (ShareToWeibo *)sharedInstance
{
    static ShareToWeibo *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToWeibo alloc] init];
    });
    return sharedInstance;
}


- (void)initWeiboWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    _appKey = appKey;
    _appSecret = appSecret;
    _redirectUri = redirectUri;
}
- (void)setCompletionBlock:(ShareWeiboBlock)aCompletionBlock{
    _completionBlock = [aCompletionBlock copy];
}
- (void)setFailedBlock:(ShareWeiboBlock)aFailedBlock{
    _failureBlock = [aFailedBlock copy];
}
- (void)setCompletionTokenBlock:(ObtainWeiboTokenBlock)aCompletionBlock {
    _completionTokenBlock = [aCompletionBlock copy];
}
- (void)setFailedTokenBlock:(ObtainWeiboTokenBlock)aFailedBlock {
    _failureTokenBlock = [aFailedBlock copy];
}

#pragma mark - OAuth方式获取token
- (void)obtainAccessTokenWithCompletionBlock:(ObtainWeiboTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainWeiboTokenBlock)aFailedBlock
{
    [self setCompletionTokenBlock:aCompletionBlock];
    [self setFailedTokenBlock:aFailedBlock];

    _webViewController = [[SMWebViewController alloc] initWithTitle:Locale(@"sm.weibo")];
    _webViewController.webDelegate = self;
    if ([ShareManager sharedManager].presentViewController) {
        [[ShareManager sharedManager].presentViewController presentViewController:_webViewController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_webViewController animated:YES completion:nil];
    }

    _webView = _webViewController.webView;
    _webView.delegate = self;
    
    _consumer = [[OAConsumer alloc] initWithKey:_appKey secret:_appSecret];
    NSURL *requestTokenUrl = requestTokenUrl = [NSURL URLWithString:WEIBO_AUTHORIZE_URL];
    OAMutableURLRequest *requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:_consumer
                                                                                  token:nil
                                                                                  realm:nil
                                                                      signatureProvider:nil];
    
    OARequestParameter* clientIdParam = [[OARequestParameter alloc] initWithName:@"client_id" value:_appKey];
    OARequestParameter* responseTypeParam = [[OARequestParameter alloc] initWithName:@"response_type" value:@"code"];
    OARequestParameter* redirectUriParam = [[OARequestParameter alloc] initWithName:@"redirect_uri" value:_redirectUri];
    NSHTTPCookieStorage *allCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];  
    NSArray *cookieArray=[allCookie cookiesForURL:requestTokenRequest.URL];//request.URL即为请求的源地址
    for(id obj in cookieArray)
    {
        [allCookie deleteCookie:obj];
    }
    NSArray *params = @[clientIdParam, responseTypeParam, redirectUriParam];
    [requestTokenRequest setHTTPMethod:@"GET"];
    [requestTokenRequest setParameters:[NSArray arrayWithArray:params]];
    requestTokenRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [_webView loadRequest:requestTokenRequest];
}
- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    if (data) {
        
        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _accessToken  = [dic objectForKey:@"access_token"];
        //save access token
        [[NSUserDefaults standardUserDefaults] setValue:_accessToken forKey:WEIBO_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(_completionTokenBlock){
            _completionTokenBlock();
        }
    }
    if (!_accessToken) {
        if (_failureTokenBlock) {
            _failureTokenBlock();
        }
    }
    _completionTokenBlock = nil;
    _failureTokenBlock = nil;
}
- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
    // ERROR!
    if(_failureTokenBlock){
        _failureTokenBlock();
    }
    _completionTokenBlock = nil;
    _failureTokenBlock = nil;
}



#pragma mark - OAuth方式分享
- (void)shareOAuthWithContent:(SMContent *)content
                completionBlock:(ShareWeiboBlock)aCompletionBlock
                    failedBlock:(ShareWeiboBlock)aFailedBlock
{
    [self setCompletionBlock:aCompletionBlock];
    [self setFailedBlock:aFailedBlock];
    
    _content = content;
    
    //load access token
    _accessToken = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:WEIBO_ACCESS_TOKEN];
    if (!_accessToken) {
        
        [self obtainAccessTokenWithCompletionBlock:^ {
        
            [self didUpdate];
            return;
            
        } failedBlock:^ {
            
            [_webViewController dismiss];
            if(_failureBlock){
                _failureBlock(ShareContentStateFail);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        }];

    } else {
        [self didUpdate];
    }
}


- (void)didUpdate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        if (_content.image) {
            NSURL* updateUrl = [NSURL URLWithString:WEIBO_UPLOAD_URL];
            [request setURL: updateUrl];
            [request setHTTPMethod:@"POST"];
            
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            //  parameter pic
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:_content.image.compressedData];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            //  parameter status
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[_content.desc dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // parameter access_token
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[_accessToken dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            
        } else {
            NSURL* updateUrl = [NSURL URLWithString:WEIBO_UPDATE_URL];
            [request setURL: updateUrl];
            [request setHTTPMethod:@"POST"];
            
            NSString *str = [NSString stringWithFormat:@"status=%@&access_token=%@", _content.desc, _accessToken];
            NSData *body = [str dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:body];
        }
        
        NSError *error;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        NSString *returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"error description: %@", error.description);
            if(_failureBlock){
                _failureBlock(ShareContentStateFail);
            }
        } else {
            NSLog(@"%@", returnStr);
            if(_completionBlock){
                _completionBlock(ShareContentStateSuccess);
            }
        }
        _completionBlock = nil;
        _failureBlock = nil;
    });
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //  [indicator startAnimating];
    NSString *temp = [NSString stringWithFormat:@"%@",request];
    NSRange textRange = [[temp lowercaseString] rangeOfString:[_redirectUri lowercaseString]];
    
    if(textRange.location != NSNotFound){
        
        
        // Extract oauth_verifier from URL query
        NSString* code = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                code = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        NSLog(@"code : %@", code);
        if (code) {
            NSURL* accessTokenUrl = [NSURL URLWithString:WEIBO_ACCESS_TOKEN_URL];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:_consumer token:nil realm:nil signatureProvider:nil];
            OARequestParameter* clientIdParam = [[OARequestParameter alloc] initWithName:@"client_id" value:_appKey];
            OARequestParameter* clientSecretParam = [[OARequestParameter alloc] initWithName:@"client_secret" value:_appSecret];
            OARequestParameter* grantTypeParam = [[OARequestParameter alloc] initWithName:@"grant_type" value:@"authorization_code"];
            OARequestParameter* redirectUriParam = [[OARequestParameter alloc] initWithName:@"redirect_uri" value:_redirectUri];
            OARequestParameter* codeParam = [[OARequestParameter alloc] initWithName:@"code" value:code];
            NSArray *params = @[clientIdParam, clientSecretParam, grantTypeParam, redirectUriParam, codeParam];
            
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithArray:params]];
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                              didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
        }
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [_webViewController dismiss];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:_webViewController.view animated:YES];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    // ERROR!
    [_webViewController stopLoading];
    [_webViewController dismiss];
    //102错误码是因为微博开发者账号设置的回调地址无效，这里不处理
    if (error.code != 102) {
        if (_failureTokenBlock) {
            _failureTokenBlock();
        }
        _completionTokenBlock = nil;
        _failureTokenBlock = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:_webViewController.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_webViewController stopLoading];
    
    [MBProgressHUD hideAllHUDsForView:_webViewController.view animated:YES];
}

- (void)SMWebClose
{
    if(_failureBlock)
    {
        _failureBlock(ShareContentStateFail);
    }
    _failureBlock = NULL;
    [_webView stopLoading];
}

@end
