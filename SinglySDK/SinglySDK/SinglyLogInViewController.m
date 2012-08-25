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
    SinglySession* session_;
    UIWebView* webview_;
    NSString* targetService;
    NSMutableData* responseData;
    UIView* pendingLoginView;
    UIActivityIndicatorView* activityView;
}
-(void)processAccessTokenWithData:(NSData*)data;
@end

@implementation SinglyLogInViewController

@synthesize clientID = _clientID, clientSecret =_clientSecret, scope =_scope, flags = _flags;

- (id)initWithSession:(SinglySession*)session forService:(NSString*)serviceId;
{
    self = [super init];
    if (self) {
        session_ = session;
        targetService = serviceId;
        webview_ = [[UIWebView alloc] initWithFrame:self.view.frame];
        webview_.scalesPageToFit = YES;
        webview_.delegate = self;
        self.view = webview_;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (void)viewWillAppear:(BOOL)animated;
{
    NSString* urlStr = [NSString stringWithFormat:@"https://api.singly.com/oauth/authorize?redirect_uri=singly://authComplete&service=%@&client_id=%@", targetService, self.clientID];
    if (session_.accountID) {
        urlStr = [urlStr stringByAppendingFormat:@"&account=%@", session_.accountID];
    }
    if (self.scope) {
        urlStr = [urlStr stringByAppendingFormat:@"&scope=%@", self.scope];
    }
    if (self.flags) {
        urlStr = [urlStr stringByAppendingFormat:@"&flag=%@", self.flags];
    }
    [webview_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}
-(void)processAccessTokenWithData:(NSData*)data;
{
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if ([request.URL.scheme isEqualToString:@"singly"] && [request.URL.host isEqualToString:@"authComplete"]) {

        pendingLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
        pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(140, 180, activityView.bounds.size.width, activityView.bounds.size.height);
        [pendingLoginView addSubview:activityView];
        [activityView startAnimating];
        
        [self.view addSubview:pendingLoginView];
        [self.view bringSubviewToFront:pendingLoginView];
        
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
            NSURL* accessTokenURL = [NSURL URLWithString:@"https://api.singly.com/oauth/access_token"];
            NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:accessTokenURL];
            req.HTTPMethod = @"POST";
            req.HTTPBody = [[NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", self.clientID, self.clientSecret, [parameters objectForKey:@"code"]] dataUsingEncoding:NSUTF8StringEncoding];
            responseData = [NSMutableData data];
            [NSURLConnection connectionWithRequest:req delegate:self];
        }
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
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    NSError* error;
    NSDictionary* jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (error) {
        if (session_.delegate) {
            [session_.delegate singlySession:session_ errorLoggingInToService:targetService withError:error];
        }
        return;
    }
    
    NSString* loginError = [jsonResult objectForKey:@"error"];
    if (loginError) {
        if (session_.delegate) {
            NSError* error = [NSError errorWithDomain:@"SinglySDK" code:100 userInfo:[NSDictionary dictionaryWithObject:loginError forKey:NSLocalizedDescriptionKey]];
            [session_.delegate singlySession:session_ errorLoggingInToService:targetService withError:error];
        }
        return;
    }
    
    // Save the access token and account id
    session_.accessToken = [jsonResult objectForKey:@"access_token"];
    session_.accountID = [jsonResult objectForKey:@"account"];
    if (session_.delegate) {
        [session_.delegate singlySession:session_ didLogInForService:targetService];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (session_.delegate) {
        [session_.delegate singlySession:session_ errorLoggingInToService:targetService withError:error];
    }
}
@end
