//
//  ShareToTwitter.m
//  ShareManager
//
//  Created by Jerry on 12/22/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "ShareToTwitter.h"

@interface ShareToTwitter() <UIWebViewDelegate>
@property (nonatomic, strong) SMWebViewController *webViewController;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) SMContent *content;
@property (nonatomic, strong) NSString *media_ids;
@end;

@implementation ShareToTwitter

+ (ShareToTwitter *)sharedInstance
{
    static ShareToTwitter *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareToTwitter alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 初始化
- (void)initTwitterWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri
{
    _appKey = appKey;
    _appSecret = appSecret;
    _redirectUri = redirectUri;
    _consumer = [[OAConsumer alloc] initWithKey:_appKey secret:_appSecret];
}
- (void)setCompletionBlock:(ShareTwitterBlock)aCompletionBlock{
    _completionBlock = [aCompletionBlock copy];
}
- (void)setFailedBlock:(ShareTwitterBlock)aFailedBlock{
    _failureBlock = [aFailedBlock copy];
}
- (void)setCompletionTokenBlock:(ObtainFacebookTokenBlock)aCompletionBlock {
    _completionTokenBlock = [aCompletionBlock copy];
}
- (void)setFailedTokenBlock:(ObtainFacebookTokenBlock)aFailedBlock {
    _failureTokenBlock = [aFailedBlock copy];
}


#pragma mark - OAuth方式获取token
- (void)obtainAccessTokenWithCompletionBlock:(ObtainTwitterTokenBlock)aCompletionBlock
                                 failedBlock:(ObtainTwitterTokenBlock)aFailedBlock
{
    [self setCompletionTokenBlock:aCompletionBlock];
    [self setFailedTokenBlock:aFailedBlock];
    
    _webViewController = [[SMWebViewController alloc] initWithTitle:Locale(@"sm.twitter")];
    if ([ShareManager sharedManager].presentViewController) {
        [[ShareManager sharedManager].presentViewController presentViewController:_webViewController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_webViewController animated:YES completion:nil];
    }

    _webView = _webViewController.webView;
    _webView.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:_webViewController.view animated:YES];
    NSURL* requestTokenUrl = [NSURL URLWithString:TWITTER_REQUEST_TOKEN_URL];
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:_consumer
                                                                                  token:nil
                                                                                  realm:nil
                                                                      signatureProvider:nil];
    
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:_redirectUri];
    [requestTokenRequest setHTTPMethod:@"POST"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];
}
- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    
    NSURL* authorizeUrl = [NSURL URLWithString:TWITTER_AUTHORIZE_URL];
    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                            consumer:nil
                                                                               token:nil
                                                                               realm:nil
                                                                   signatureProvider:nil];
    NSString* oauthToken = _requestToken.key;
    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
    
    [_webView loadRequest:authorizeRequest];
}
- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (data) {
        _accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
        //save access token
        [_accessToken storeInUserDefaultsWithServiceProviderName:TWITTER_ACCESS_TOKEN prefix:nil];
        if(_completionTokenBlock){
            _completionTokenBlock();
        }
    }
    if (!_accessToken) {
        if(_failureTokenBlock){
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
                  completionBlock:(ShareTwitterBlock)aCompletionBlock
                      failedBlock:(ShareTwitterBlock)aFailedBlock
{
    [self setCompletionBlock:aCompletionBlock];
    [self setFailedBlock:aFailedBlock];
    _content = content;
    
    //load access token
    _accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:TWITTER_ACCESS_TOKEN prefix:nil];
    if (!_accessToken) {

        [self obtainAccessTokenWithCompletionBlock:^ {
                    
            if (_content.image) {
                [self didUploadMedia];
            } else {
                [self didUpdate];
            }
            
        } failedBlock:^ {
            
            [_webViewController dismiss];
            if (_failureBlock) {
                _failureBlock(ShareContentStateFail);
            }
            _completionBlock = nil;
            _failureBlock = nil;
        }];
        
    } else {
        
        if (_content.image) {
            [self didUploadMedia];
        } else {
            [self didUpdate];
        }
    }
}
- (void)didUploadMedia
{
    NSURL* uploadUrl = [NSURL URLWithString:TWITTER_UPLOAD_URL];
    OAMutableURLRequest* uploadRequest = [[OAMutableURLRequest alloc] initWithURL:uploadUrl
                                                                         consumer:_consumer
                                                                            token:_accessToken
                                                                            realm:nil
                                                                signatureProvider:nil];
    
    
    NSString *imageBase64Str = [_content.image.compressedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *media = imageBase64Str;
    
    OARequestParameter* mediaParam = [[OARequestParameter alloc] initWithName:@"media" value:media];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setParameters:[NSArray arrayWithObject:mediaParam]];
    OADataFetcher* mediaDataFetcher = [[OADataFetcher alloc] init];
    [mediaDataFetcher fetchDataWithRequest:uploadRequest
                                  delegate:self
                         didFinishSelector:@selector(didUploadMediaSuccess:data:)
                           didFailSelector:@selector(didUploadMediaFail:data:)];
}
- (void)didUploadMediaSuccess:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"post media : %@", httpBody);
    
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    _media_ids= ((NSNumber *)[dic objectForKey:@"media_id"]).stringValue;
    [self didUpdate];
}
- (void)didUploadMediaFail:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"fail media : %@", httpBody);
    if(_failureBlock){
        _failureBlock(ShareContentStateSuccess);
    }
    _completionBlock = nil;
    _failureBlock = nil;
}
- (void)didUpdate
{
    NSURL* updateUrl = [NSURL URLWithString:TWITTER_UPDATE_URL];
    OAMutableURLRequest* updateRequest = [[OAMutableURLRequest alloc] initWithURL:updateUrl
                                                                         consumer:_consumer
                                                                            token:_accessToken
                                                                            realm:nil
                                                                signatureProvider:nil];
    
    OARequestParameter* statusParam = [[OARequestParameter alloc] initWithName:@"status" value:_content.desc];
    NSMutableArray *arr = [NSMutableArray arrayWithObject:statusParam];
    if (_media_ids) {
        OARequestParameter *mediaParam = [[OARequestParameter alloc] initWithName:@"media_ids" value:_media_ids];
        [arr addObject:mediaParam];
    }
    [updateRequest setHTTPMethod:@"POST"];
    [updateRequest setParameters:[NSArray arrayWithArray:arr]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:updateRequest
                             delegate:self
                    didFinishSelector:@selector(didUpdateSuccess:data:)
                      didFailSelector:@selector(didUpdateFail:data:)];
}
- (void)didUpdateSuccess:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"post tweet : %@", httpBody);
    if(_completionBlock){
        _completionBlock(ShareContentStateSuccess);
    }
    _completionBlock = nil;
    _failureBlock = nil;
}
- (void)didUpdateFail:(OAServiceTicket*)ticket data:(NSData*)data {
    
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"fail tweet : %@", httpBody);
    if(_failureBlock){
        _failureBlock(ShareContentStateSuccess);
    }
    _completionBlock = nil;
    _failureBlock = nil;
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //  [indicator startAnimating];
    NSString *temp = [NSString stringWithFormat:@"%@",request];
    NSRange textRange = [[temp lowercaseString] rangeOfString:[_redirectUri lowercaseString]];
    
    if(textRange.location != NSNotFound){
        
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            NSURL* accessTokenUrl = [NSURL URLWithString:TWITTER_ACCESS_TOKEN_URL];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:_consumer token:_requestToken realm:nil signatureProvider:nil];
            OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
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
