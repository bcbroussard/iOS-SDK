//
//  SinglyLogInViewController.m
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglyLogInViewController.h"

@interface SinglyLogInViewController ()
{
    UIWebView* _webview;
    NSString* _targetService;
    NSMutableData* _responseData;
    UIView* pendingLoginView;
    UIActivityIndicatorView* activityView;

    id __unsafe_unretained _delegate;
}

-(void)processAccessTokenWithData:(NSData*)data;

@end

@implementation SinglyLogInViewController

@synthesize scope =_scope, flags = _flags, delegate =_delegate;

- (id)initWithService:(NSString*)serviceId;
{
    self = [super init];
    if (self) {
        _targetService = serviceId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webview.scalesPageToFit = YES;
    _webview.delegate = self;
    [self.view addSubview:_webview];
    
    pendingLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
    pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    pendingLoginView.hidden =YES;

    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(140, 180, activityView.bounds.size.width, activityView.bounds.size.height);
    
    [pendingLoginView addSubview:activityView];
    [activityView startAnimating];
    
    [_webview addSubview:pendingLoginView];


    SinglyClient *client = [SinglyClient sharedClient];
    
    NSString* urlStr = [NSString stringWithFormat:@"https://api.singly.com/oauth/authorize?redirect_uri=singly://authComplete&service=%@&client_id=%@", _targetService, client.clientId];
    
    if ([client.accountId length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"&account=%@",  client.accountId];
    }
    if ([self.scope length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"&scope=%@", self.scope];
    }
    if ([self.flags length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"&flag=%@", self.flags];
    }
    DLog(@"Going to auth url %@", urlStr);
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)processAccessTokenWithData:(NSData*)data;
{
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if ([request.URL.scheme isEqualToString:@"singly"] && [request.URL.host isEqualToString:@"authComplete"]) {

        pendingLoginView.hidden =NO;
        
        // Find the code and request an access token
        NSArray *parameterPairs = [request.URL.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
        
        for (NSString *currentPair in parameterPairs) {
            NSArray *pairComponents = [currentPair componentsSeparatedByString:@"="];
            
            NSString *key = ([pairComponents count] >= 1 ? [pairComponents objectAtIndex:0] : nil);
            if (key == nil) continue;
            
            NSString *value = ([pairComponents count] >= 2 ? [pairComponents objectAtIndex:1] : [NSNull null]);
            [parameters setObject:value forKey:key];
        }
        
        if ([parameters objectForKey:@"code"]) {
            SinglyClient *client = [SinglyClient sharedClient];
            
            NSURL* accessTokenURL = [NSURL URLWithString:@"https://api.singly.com/oauth/access_token"];
            NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:accessTokenURL];
            req.HTTPMethod = @"POST";
            req.HTTPBody = [[NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", client.clientId, client.clientSecret, [parameters objectForKey:@"code"]] dataUsingEncoding:NSUTF8StringEncoding];
            _responseData = [NSMutableData data];
            [NSURLConnection connectionWithRequest:req delegate:self];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //TODO:  Fill this in
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    NSError* error;
    NSDictionary* jsonResult = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    SinglyClient *client = [SinglyClient sharedClient];
    
    DLog(@"All set to do requests as account %@ with access token %@", client.accountId, client.accessToken);
    if (error) {
        if (_delegate) {
            [_delegate singlyErrorLoggingInToService:_targetService withError:error];
        }
        return;
    }
    
    NSString* loginError = [jsonResult objectForKey:@"error"];
    if (loginError) {
        if (_delegate) {
            NSError* error = [NSError errorWithDomain:@"SinglySDK" code:100 userInfo:[NSDictionary dictionaryWithObject:loginError forKey:NSLocalizedDescriptionKey]];
            [_delegate singlyErrorLoggingInToService:_targetService withError:error];
        }
        return;
    }
    
    // Save the access token and account id
    if (_delegate) {
        client.accessToken = [jsonResult objectForKey:@"access_token"];
        client.accountId = [jsonResult objectForKey:@"account"];

        [_delegate singlyDidLogInForService:_targetService];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_delegate) {
        [_delegate singlyErrorLoggingInToService:_targetService withError:error];
    }
}
@end
