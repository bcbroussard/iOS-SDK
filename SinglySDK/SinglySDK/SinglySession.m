//
//  SinglySession.m
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/21/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglySession.h"

static NSString* kSinglyAccountIDKey = @"com.singly.accountID";
static NSString* kSinglyAccessTokenKey = @"com.singly.accessToken";

@implementation SinglySession
@synthesize delegate =_delegate;

-(void)setAccountID:(NSString *)accountID
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];    
    [_userDefaults setObject:accountID forKey:kSinglyAccountIDKey];
    [_userDefaults synchronize];
}

-(NSString*)accountID;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSinglyAccountIDKey];
}

-(void)setAccessToken:(NSString *)accessToken;
{
    DLog(@"Saved accesstoken");
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];    
    [_userDefaults setObject:accessToken forKey:kSinglyAccessTokenKey];
    [_userDefaults synchronize];

}

-(NSString*)accessToken;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSinglyAccessTokenKey];
}

-(void)checkReadyWithBlock:(void (^)(BOOL))block;
{
    // If we don't have an accountID or accessToken we're definitely not ready
    if (!self.accountID || !self.accessToken) {
        return block(NO);
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.singly.com/v0/profiles?access_token=%@", self.accessToken]]];
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSString* foundAccountID = [json objectForKey:@"id"];
        BOOL isReady = NO;
        if ([foundAccountID isEqualToString:self.accountID]) {
            isReady = YES;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(isReady);
        });
    });
    
}

-(NSString*)escapeString:(NSString*)rawString;
{
    CFStringRef originalString = (__bridge_retained CFStringRef)rawString;
    NSString* finalString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, originalString, NULL, NULL, kCFStringEncodingUTF8);
    CFRelease(originalString);
    return finalString;
}

-(void)requestAPI:(NSString*)api withParameters:(NSDictionary*)params;
{
    if (!self.accessToken) {
        if (self.delegate) {
            NSError* error = [NSError errorWithDomain:@"SinglySDK" code:100 userInfo:[NSDictionary dictionaryWithObject:@"Access token is not yet set" forKey:NSLocalizedDescriptionKey]];
            return [self.delegate singlyErrorForAPI:api withError:error];
        }
    }
    NSString* apiURLStr = [NSString stringWithFormat:@"https://api.singly.com/v0/%@?access_token=%@", api, self.accessToken];
    if (params) {
        NSMutableString* paramString = [NSMutableString string];
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![obj isKindOfClass:[NSNull class]]) {
                [paramString appendFormat:@"&%@=%@", [self escapeString:key], [self escapeString:obj]];
            }
        }];
        apiURLStr = [apiURLStr stringByAppendingString:paramString];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:apiURLStr]];
        NSError* error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error && self.delegate) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate singlyErrorForAPI:api withError:error];
            });
            return;
        }
        
        if (self.delegate) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate singlyResultForAPI:api withJSON:json];
            });
        }
    });
}
@end
