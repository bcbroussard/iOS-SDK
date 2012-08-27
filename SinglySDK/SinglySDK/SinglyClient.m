//
//  SinglyClient.m
//  SinglySDK
//
//  Created by BC Broussard on 8/24/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglyClient.h"
#import "SinglySDK.h"
#import "SSKeychain.h"

#define SINGLY_BASE_API_URL(api) [NSString stringWithFormat:@"https://api.singly.com/v0/%@", api]

#define SINGLY_TYPES_API_URL(type, endPoint) [NSString stringWithFormat:@"%@/%@/%@", SINGLY_BASE_API_URL(@"types"), type, endPoint]
#define SINGLY_SERVICES_API_URL(service, endPoint) [NSString stringWithFormat:@"%@/%@/%@", SINGLY_BASE_API_URL(@"services"), service, endPoint]

//Credentials
#define SINGLY_KEYCHAIN_NAME [[NSBundle mainBundle] bundleIdentifier]

static NSString *const kSinglyAccessTokenKey=@"accessToken";
static NSString *const kSinglyAccountIdKey=@"accountId";


@interface SinglyClient ()
- (void)flushAccessTokens; 
- (void) setPassword:(NSString *)password forKey:(NSString *)keyId;
- (NSString*)getPasswordWithKey:(NSString *) keyId;

@end

@implementation SinglyClient
@synthesize clientId = _clientId, clientSecret = _clientSecret;


-(void)setAccountId:(NSString *)accountId
{
    [self setPassword:accountId forKey:kSinglyAccountIdKey];
}

-(NSString*)accountId;
{
    return [self getPasswordWithKey:kSinglyAccountIdKey];
}

-(void)setAccessToken:(NSString *)accessToken;
{
    [self setPassword:accessToken forKey:kSinglyAccessTokenKey];

}
-(NSString*)accessToken;
{
    return [self getPasswordWithKey:kSinglyAccessTokenKey];
}

-(BOOL) isLoggedIn
{
    return [[self accessToken] length] != 0;
}

- (void)logout
{    
    [self flushAccessTokens];
}


- (void)flushAccessTokens 
{    
#if TARGET_IPHONE_SIMULATOR    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kSinglyAccountIdKey];
    [defaults removeObjectForKey:kSinglyAccessTokenKey];
    [defaults synchronize];

    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];    
    [_userDefaults setObject:accessToken forKey:key];    
    [_userDefaults synchronize];
#else
    
    [SSKeychain deletePasswordForService:SINGLY_KEYCHAIN_NAME account:kSinglyAccountIdKey];
    [SSKeychain deletePasswordForService:SINGLY_KEYCHAIN_NAME account:kSinglyAccessTokenKey];
    
#endif
    
    
}

// Using NSUserDefaults for storage is very insecure, but because Keychain only exists on a device
// we use NSUserDefaults when running on the simulator to store objects.  This allows you to still test
// in the simulator.  You should NOT modify in a way that does not use keychain when actually deployed to a device.

-(void) setPassword:(NSString *)password forKey:(NSString *)keyId
{
    
#if TARGET_IPHONE_SIMULATOR    
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];    
    [_userDefaults setObject:accessToken forKey:keyId];    
    [_userDefaults synchronize];
#else
    
    [SSKeychain setPassword:password forService:SINGLY_KEYCHAIN_NAME account:keyId];
    
#endif
}

-(NSString*)getPasswordWithKey:(NSString *) keyId;
{
#if TARGET_IPHONE_SIMULATOR
    NSString *key = [NSString stringWithFormat:@"%@.%@", SINGLY_KEYCHAIN_NAME, keyId];
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
#else
	return [SSKeychain passwordForService:SINGLY_KEYCHAIN_NAME 
								  account:keyId
									error:nil ];
#endif
    
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

+(void) requestTypesAPI:kSinglyApiName 
                 withPath:(NSString*)commandPath
            andParameters:(NSDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;
{
    [[self sharedClient] requestAPI:SINGLY_TYPES_API_URL(kSinglyApiName, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];
    
}


#pragma mark - Service Methods

+(void) requestServiceAPI:kSinglyApiName 
          withPath:(NSString*)commandPath
    andParameters:(NSDictionary*)params
andCompletionBlock:(SEResponseBlock) completionBlock 
           onError:(SEErrorBlock) errorBlock;
{
    [[self sharedClient] requestAPI:SINGLY_SERVICES_API_URL(kSinglyApiName, commandPath) withParameters:params andCompletionBlock:completionBlock onError:errorBlock];

}

+(void) requestGoogle:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGoogle withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestInstagram:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceInstagram withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestTwitter:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceTwitter withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestZeo:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceZeo withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestLinkedIn:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceLinkedin withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestTumblr:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceTumblr withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGDocs:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGdocs withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGContacts:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGContacts withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestFitbit:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceFitbit withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGmail:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGMail withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestMeetup:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceMeetup withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestFoursquare:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceFoursquare withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestRunkeeper:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceRunkeeper withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestEmail:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceEmail withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestBodymedia:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceBodymedia withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestFacebook:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceFacebook withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestDropbox:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceDropbox withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestYammer:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceYammer withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGplus:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGPlus withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestGithub:(NSString*)commandPath
           withParameters:(NSMutableDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceGithub withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}

+(void) requestWithings:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;
{
    
    [self requestServiceAPI:kSinglyServiceWithings withPath:commandPath andParameters:params andCompletionBlock:completionBlock onError:errorBlock];
}



@end
