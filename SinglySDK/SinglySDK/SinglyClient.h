//
//  SinglyEngine.h
//  SinglySDK
//
//  Created by BC Broussard on 8/24/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "MKNetworkKit.h"

@interface SinglyClient : MKNetworkEngine

typedef void (^SEResponseBlock)(id jsonResponse);
typedef void (^SEErrorBlock)(NSError *error);

@property (strong, nonatomic) NSString* accessToken;
@property (strong, nonatomic) NSString* accountId;
@property (strong, nonatomic) NSString* clientId;
@property (strong, nonatomic) NSString* clientSecret;


@property (nonatomic, readonly) BOOL isLoggedIn;

-(void) requestAPI:(NSString*)apiUrl
                   withParameters:(NSDictionary*)params
               andCompletionBlock:(SEResponseBlock) completionBlock 
                          onError:(SEErrorBlock) errorBlock;

+ (SinglyClient *)sharedClient;

+(void) requestFacebook:(NSString*)commandPath
         withParameters:(NSDictionary*)params
     andCompletionBlock:(SEResponseBlock) completionBlock 
                onError:(SEErrorBlock) errorBlock;

+(void) requestTwitter:(NSString*)commandPath
        withParameters:(NSDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;

+(void) requestInstagram:(NSString*)commandPath
          withParameters:(NSDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;

+(void) requestFoursquare:(NSString*)commandPath
           withParameters:(NSMutableDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;

+(void) requestGithub:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestGoogleContacts:(NSString*)commandPath
               withParameters:(NSMutableDictionary*)params
           andCompletionBlock:(SEResponseBlock) completionBlock 
                      onError:(SEErrorBlock) errorBlock;

@end
