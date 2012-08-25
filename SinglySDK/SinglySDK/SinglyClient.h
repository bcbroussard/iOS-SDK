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

+(void) requestServiceAPI:kSinglyApiName 
                 withPath:(NSString*)commandPath
            andParameters:(NSDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;

+(void) requestGoogle:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestInstagram:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;

+(void) requestTwitter:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;

+(void) requestZeo:(NSString*)commandPath
    withParameters:(NSMutableDictionary*)params
andCompletionBlock:(SEResponseBlock) completionBlock 
           onError:(SEErrorBlock) errorBlock;

+(void) requestLinkedIn:(NSString*)commandPath
         withParameters:(NSMutableDictionary*)params
     andCompletionBlock:(SEResponseBlock) completionBlock 
                onError:(SEErrorBlock) errorBlock;

+(void) requestTumblr:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestGDocs:(NSString*)commandPath
      withParameters:(NSMutableDictionary*)params
  andCompletionBlock:(SEResponseBlock) completionBlock 
             onError:(SEErrorBlock) errorBlock;

+(void) requestGContacts:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;

+(void) requestFitbit:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestGmail:(NSString*)commandPath
      withParameters:(NSMutableDictionary*)params
  andCompletionBlock:(SEResponseBlock) completionBlock 
             onError:(SEErrorBlock) errorBlock;

+(void) requestMeetup:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestFoursquare:(NSString*)commandPath
           withParameters:(NSMutableDictionary*)params
       andCompletionBlock:(SEResponseBlock) completionBlock 
                  onError:(SEErrorBlock) errorBlock;

+(void) requestRunkeeper:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;

+(void) requestEmail:(NSString*)commandPath
      withParameters:(NSMutableDictionary*)params
  andCompletionBlock:(SEResponseBlock) completionBlock 
             onError:(SEErrorBlock) errorBlock;

+(void) requestBodymedia:(NSString*)commandPath
          withParameters:(NSMutableDictionary*)params
      andCompletionBlock:(SEResponseBlock) completionBlock 
                 onError:(SEErrorBlock) errorBlock;

+(void) requestFacebook:(NSString*)commandPath
         withParameters:(NSMutableDictionary*)params
     andCompletionBlock:(SEResponseBlock) completionBlock 
                onError:(SEErrorBlock) errorBlock;

+(void) requestDropbox:(NSString*)commandPath
        withParameters:(NSMutableDictionary*)params
    andCompletionBlock:(SEResponseBlock) completionBlock 
               onError:(SEErrorBlock) errorBlock;

+(void) requestYammer:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestGplus:(NSString*)commandPath
      withParameters:(NSMutableDictionary*)params
  andCompletionBlock:(SEResponseBlock) completionBlock 
             onError:(SEErrorBlock) errorBlock;

+(void) requestGithub:(NSString*)commandPath
       withParameters:(NSMutableDictionary*)params
   andCompletionBlock:(SEResponseBlock) completionBlock 
              onError:(SEErrorBlock) errorBlock;

+(void) requestWithings:(NSString*)commandPath
         withParameters:(NSMutableDictionary*)params
     andCompletionBlock:(SEResponseBlock) completionBlock 
                onError:(SEErrorBlock) errorBlock;

@end
