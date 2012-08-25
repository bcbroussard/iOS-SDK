//
//  SinglyLogInViewController.h
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglySession.h"

@interface SinglyLogInViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDataDelegate>
/*!
 Initialize with a session and service
 @param session
    The session that the login will be saved into.
 @param serviceId
    The name of the service that we are logging into.
*/
- (id)initWithSession:(SinglySession*)session forService:(NSString*)serviceId;

@property (strong, nonatomic) NSString* clientID;
@property (strong, nonatomic) NSString* clientSecret;
@property (strong, nonatomic) NSString* scope;
@property (strong, nonatomic) NSString* flags;

@end
