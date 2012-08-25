//
//  SinglyLogInViewController.h
//  SinglySDK
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglyClient.h"

@interface SinglyLogInViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDataDelegate>
- (id)initWithService:(NSString*)serviceId;

@property (strong, nonatomic) NSString* scope;
@property (strong, nonatomic) NSString* flags;

@end
