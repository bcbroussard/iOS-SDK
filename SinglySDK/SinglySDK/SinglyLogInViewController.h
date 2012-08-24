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
- (id)initWithSession:(SinglySession*)session forService:(NSString*)serviceId;

@property (strong, nonatomic) NSString* clientID;
@property (strong, nonatomic) NSString* clientSecret;
@property (strong, nonatomic) NSString* scope;
@property (strong, nonatomic) NSString* flags;

@end
