//
//  ShareToFacebook.m
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareToFacebook.h"
#import "ShareManager.h"
#import "OAuthConsumer.h"
#import "SMWebViewController.h"

@interface ShareToFacebook() <UIWebViewDelegate>
@property (nonatomic, strong) SMWebViewController *webViewController;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) SMContent *content;
@end;

@implementation ShareToFacebook

+ (ShareToFacebook *)sharedInstance
{
    static ShareToFacebook *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToFacebook alloc] init];
    });
    return sharedInstance;
}

- (void)initFacebookWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    _appKey = appKey;
    _appSecret = appSecret;
    _redirectUri = redirectUri;
}
- (void)setCompletionBlock:(ShareFacebookBlock)aCompletionBlock {
    _completionBlock = [aCompletionBlock copy];
}
- (void)setFailedBlock:(ShareFacebookBlock)aFailedBlock {
    _failureBlock = [aFailedBlock copy];
}
- (void)setCompletionTokenBlock:(ObtainFacebookTokenBlock)aCompletionBlock {
    _completionTokenBlock = [aCompletionBlock copy];
}
- (void)setFailedTokenBlock:(ObtainFacebookTokenBlock)aFailedBlock {
    _failureTokenBlock = [aFailedBlock copy];
}

#pragma mark - OAuth方式获取token
- (void)obtainAccessTokenWithCompletionBlock:(ObtainFacebookTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainFacebookTokenBlock)aFailedBlock
{
    [self setCompletionTokenBlock:aCompletionBlock];
    [self setFailedTokenBlock:aFailedBlock];
    
    _webViewController = [[SMWebViewController alloc] initWithTitle:Locale(@"sm.facebook")];
    if ([ShareManager sharedManager].presentViewController) {
        [[ShareManager sharedManager].presentViewController presentViewController:_webViewController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_webViewController animated:YES completion:nil];
    }
    _webView = _webViewController.webView;
    _webView.delegate = self;
    
    _consumer = [[OAConsumer alloc] initWithKey:_appKey secret:_appSecret];
    NSURL* requestTokenUrl = requestTokenUrl = [NSURL URLWithString:FACEBOOK_AUTHORIZE_URL];
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:_consumer
                                                                                  token:nil
                                                                                  realm:nil
                                                                      signatureProvider:nil];
    
    OARequestParameter* clientIdParam = [[OARequestParameter alloc] initWithName:@"client_id" value:_appKey];
    OARequestParameter* redirectUriParam = [[OARequestParameter alloc] initWithName:@"redirect_uri" value:_redirectUri];
    OARequestParameter* scopeParam = [[OARequestParameter alloc] initWithName:@"scope" value:@" publish_actions"];
    NSArray *params = @[clientIdParam, redirectUriParam, scopeParam];
    [requestTokenRequest setHTTPMethod:@"GET"];
    [requestTokenRequest setParameters:[NSArray arrayWithArray:params]];
    
    [_webView loadRequest:requestTokenRequest];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (data) {
        NSArray *pairs = [httpBody componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if ([[elements objectAtIndex:0] isEqualToString:@"access_token"]) {
                _accessToken = [elements objectAtIndex:1];
                [[NSUserDefaults standardUserDefaults] setValue:_accessToken forKey:FACEBOOK_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (_completionTokenBlock) {
                    _completionTokenBlock();
                }
            }
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
    if (_failureTokenBlock) {
        _failureTokenBlock();
    }
    _completionTokenBlock = nil;
    _failureTokenBlock = nil;
}

#pragma mark - OAuth方式分享
- (void)shareOAuthWithContent:(SMContent *)content
                  completionBlock:(ShareFacebookBlock)aCompletionBlock
                      failedBlock:(ShareFacebookBlock)aFailedBlock
{
    [self setCompletionBlock:aCompletionBlock];
    [self setFailedBlock:aFailedBlock];
    _content = content;
    
    //load access token
    _accessToken = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:FACEBOOK_ACCESS_TOKEN];
    if (!_accessToken) {

         [self obtainAccessTokenWithCompletionBlock:^{
             
             if (_content.image) {
                 [self didUpdateMessageAndMedia];
             } else {
                 [self didUpdateMessage];
             }
            
        } failedBlock:^{
            
            [_webViewController dismiss];
            if (_failureBlock) {
                _failureBlock(ShareContentStateFail);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        }];
        
    } else {
        if (_content.image) {
            [self didUpdateMessageAndMedia];
        } else {
            [self didUpdateMessage];
        }
    }
}

//分享图片+文字
- (void)didUpdateMessageAndMedia
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSURL* updateUrl = [NSURL URLWithString:FACEBOOK_UPLOAD_URL];
        [request setURL: updateUrl];
        [request setHTTPMethod:@"POST"];
        
        NSMutableData *body = [NSMutableData data];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        //  parameter source
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"source\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:_content.image.compressedData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        //  parameter message
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
        
        NSError *error;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        //    NSString *returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"error description: %@", error.description);
            if(_failureBlock){
                _failureBlock(ShareContentStateFail);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        } else {
            NSLog(@"photo id: %@", [dict objectForKey:@"id"]);
            if(_completionBlock){
                _completionBlock(ShareContentStateSuccess);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        }
    });
}

//分享文字
- (void)didUpdateMessage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSURL* updateUrl = [NSURL URLWithString:FACEBOOK_UPDATE_URL];
        [request setURL: updateUrl];
        [request setHTTPMethod:@"POST"];
        
        NSLog(@"update use access token: %@", _accessToken);
        NSString *str;
        str = [NSString stringWithFormat:@"message=%@&access_token=%@", _content.desc, _accessToken];
        NSData *body = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
        
        NSError *error;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        NSString *returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        //    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"error description: %@", error.description);
            if(_failureBlock){
                _failureBlock(ShareContentStateFail);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        } else {
            NSLog(@"%@", returnStr);
            if(_completionBlock){
                _completionBlock(ShareContentStateSuccess);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        }
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
        
        if (code) {
            NSURL* accessTokenUrl = [NSURL URLWithString:FACEBOOK_ACCESS_TOKEN_URL];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:_consumer token:nil realm:nil signatureProvider:nil];
            OARequestParameter* clientIdParam = [[OARequestParameter alloc] initWithName:@"client_id" value:_appKey];
            OARequestParameter* redirectUriParam = [[OARequestParameter alloc] initWithName:@"redirect_uri" value:_redirectUri];
            OARequestParameter* clientSecretParam = [[OARequestParameter alloc] initWithName:@"client_secret" value:_appSecret];
            OARequestParameter* codeParam = [[OARequestParameter alloc] initWithName:@"code" value:code];
            NSArray *params = @[clientIdParam, redirectUriParam, clientSecretParam, codeParam];
            
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
    
    [MBProgressHUD hideAllHUDsForView:_webViewController.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // [indicator stopAnimating];
    [_webViewController stopLoading];
    
    [MBProgressHUD hideAllHUDsForView:_webViewController.view animated:YES];
}

@end
