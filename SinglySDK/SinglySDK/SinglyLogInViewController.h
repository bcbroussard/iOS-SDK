//
//  SinglyLogInViewController.h
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglyClient.h"

/*!
 @protocol SinglyLoginDelegate
 @abstract Delegate methods related to a SinglySession
 */

@protocol SinglyLoginDelegate <NSObject>
@required
/*!
 Delegate method for a successful service login.
 
 @param service
 The service name for the successful login
 */
-(void)singlyDidLogInForService:(NSString*)service;
/*!
 Delegate method for an error during service login
 
 @param service
 The service name for the successful login
 @param error
 The error that occured during login
 */
-(void)singlyErrorLoggingInToService:(NSString *)service withError:(NSError*)error;
@end


@interface SinglyLogInViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDataDelegate>

/*!
 Initialize with a session and service
 
 @param serviceId
    The name of the service that we are logging into.
*/
- (id)initWithService:(NSString*)serviceId;

@property (unsafe_unretained) id<SinglyLoginDelegate> delegate;

@property (strong, nonatomic) NSString* scope;

@property (strong, nonatomic) NSString* flags;

@end