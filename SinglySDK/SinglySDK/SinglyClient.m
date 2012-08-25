//
//  SinglyClient.m
//  SinglySDK
//
//  Created by BC Broussard on 8/24/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglyClient.h"
#import "SinglySDK.h"

#define SINGLY_BASE_API_URL(api) [NSString stringWithFormat:@"https://api.singly.com/v0/%@", api]

#define SINGLY_TYPES_API_URL(type, endPoint) [NSString stringWithFormat:@"%@/%@/%@", SINGLY_BASE_API_URL(@"types"), type, endPoint]
#define SINGLY_SERVICES_API_URL(service, endPoint) [NSString stringWithFormat:@"%@/%@/%@", SINGLY_BASE_API_URL(@"services"), service, endPoint]


static NSString* kSinglyAccessTokenKey = @"com.singly.accessToken";
static NSString* kSinglyAccountIDKey = @"com.singly.accountID";

@interface SinglyClient ()
- (NSString *) encodeStringWithParams:(NSDictionary *)params;

@end

@implementation SinglyClient
@synthesize clientId = _clientId, clientSecret = _clientSecret;


-(void)setAccountId:(NSString *)accountId
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];    
    [_userDefaults setObject:accountId forKey:kSinglyAccountIDKey];
    [_userDefaults synchronize];
}

-(NSString*)accountId;
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

-(BOOL) isLoggedIn
{
    return [[self accessToken] length] != 0;
}

#pragma mark - Request methods

-(void) requestAPI:(NSString*)apiUrl
    withParameters:(NSMutableDictionary*)params
               andCompletionBlock:(SEResponseBlock) completionBlock 
                          onError:(SEErrorBlock) errorBlock
{    
    if(params == nil)
        params = [[NSMutableDictionary alloc] init];
    
    if([self isLoggedIn])
    {
        [params setObject:[self accessToken] forKey:@"access_token"];

        MKNetworkOperation *op = [self operationWithURLString:apiUrl params:params];        
        
         
        [op onCompletion:^(MKNetworkOperation *completedOperation)
         {

             id responseJson = [completedOperation responseJSON];

             // Need to parse errors from Singly with httpStatus code 200?
    //         NSError *error = [NSError errorWithDomain:@"com.singly.ErrorDomain" code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
    //         
    //         errorBlock(error);

             completionBlock(responseJson);
             
         } onError:^(NSError* error) {
             
             errorBlock(error);
         }];
        
        [self enqueueOperation:op];
    }
    else 
    {
        NSError *error = [NSError errorWithDomain:@"com.singly.ErrorDomain" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Access token is not set", NSLocalizedDescriptionKey, nil]];
        
        errorBlock(error);
    }

}
         
 - (NSString *) encodeStringWithParams:(NSDictionary *)params
{
     NSMutableString *string = [NSMutableString string];
     for (NSString *key in params) {
         
         NSObject *value = [params valueForKey:key];
         if([value isKindOfClass:[NSString class]])
             [string appendFormat:@"%@=%@&", [key urlEncodedString], [((NSString*)value) urlEncodedString]];
         else
             [string appendFormat:@"%@=%@&", [key urlEncodedString], value];
     }
     
     if([string length] > 0)
         [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
     
     return string;  
 }
         

#pragma mark - Singleton

+ (SinglyClient *)sharedClient
{
    static SinglyClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SinglyClient alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedClient;
}

#pragma mark - Service Methods

+(void) requestFacebook:(NSString*)commandPath
            withParameters:(NSMutableDictionary*)params
        andCompletionBlock:(SEResponseBlock) completionBlock 
                   onError:(SEErrorBlock) errorBlock;
{

    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceFacebook, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestTwitter:(NSString*)commandPath
            withParameters:(NSMutableDictionary*)params
        andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;
{
    
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceTwitter, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestInstagram:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceInstagram, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestFoursquare:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;
{
    
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceFoursquare, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGithub:(NSString*)commandPath
           withParameters:(NSMutableDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;
{
    
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceGithub, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGoogleContacts:(NSString*)commandPath
           withParameters:(NSMutableDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;
{
    
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyServiceGoogleContacts, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

#pragma mark - Overridden methods

//-(void)prepareHeaders:(MKNetworkOperation *)operation
//{    
//    if([self isLoggedIn])
//    {
//        [operation addHeaders:[[NSDictionary alloc] initWithObjectsAndKeys:self.zbAuthToken,@"X-AUTH-TOKEN", nil]];
//    }
//    
//}

@end
