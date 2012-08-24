//
//  SinglySession.h
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/21/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SinglySessionDelegate <NSObject>
@required
-(void)singlyResultForAPI:(NSString*)api withJSON:(id)json;
-(void)singlyErrorForAPI:(NSString*)api withError:(NSError*)error;
@end

@interface SinglySession : NSObject {
}
@property (strong, nonatomic) NSString* accessToken;
@property (strong, nonatomic) NSString* accountID;
@property (strong, nonatomic) id<SinglySessionDelegate> delegate;

-(void)checkReadyWithBlock:(void (^)(BOOL))block;
-(void)requestAPI:(NSString*)api withParameters:(NSDictionary*)params;
@end

