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
    UIActivityIndicatorView* activityView;
}

-(void)processAccessTokenWithData:(NSData*)data;

@end

@implementation SinglyLogInViewController

@synthesize scope =_scope, flags = _flags;

- (id)init
{
    self = [super init];
    if (self) {        
    }
    return self;
}

- (id)initWithService:(NSString*)serviceId;
{
    self = [self init];
    if (self) {
        _targetService = serviceId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"View did load for Singly Login");
	// Do any additional setup after loading the view.
    
    _webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webview.scalesPageToFit = YES;
    _webview.delegate = self;
    [self.view addSubview:_webview];

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
    DLog(@"Going to %@", [request.URL absoluteString]);
    DLog(@"scheme(%@) host(%@)", request.URL.scheme, request.URL.host);
    if ([request.URL.scheme isEqualToString:@"singly"] && [request.URL.host isEqualToString:@"authComplete"]) {
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
            DLog(@"Getting the tokens");
            SinglyClient *client = [SinglyClient sharedClient];
            
            NSURL* accessTokenURL = [NSURL URLWithString:@"https://api.singly.com/oauth/access_token"];
            NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:accessTokenURL];
            req.HTTPMethod = @"POST";
            req.HTTPBody = [[NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", client.clientId, client.clientSecret, [parameters objectForKey:@"code"]] dataUsingEncoding:NSUTF8StringEncoding];
            _responseData = [NSMutableData data];
            [NSURLConnection connectionWithRequest:req delegate:self];
        }
        DLog(@"Request the token");
        return FALSE;
    }
    return TRUE;
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
    client.accessToken = [jsonResult objectForKey:@"access_token"];
    client.accountId = [jsonResult objectForKey:@"account"];
    
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
    DLog(@"All set to do requests as account %@ with access token %@", client.accountId, client.accessToken);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"OH NOES: %@", error);
    // TODO:  Fill this in.
}
@end
