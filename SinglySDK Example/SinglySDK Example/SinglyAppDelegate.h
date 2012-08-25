//
//  SinglyAppDelegate.h
//  SinglySDK Example
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglyClient.h"

#define ApplicationDelegate ((SinglyAppDelegate *)[UIApplication sharedApplication].delegate)

@interface SinglyAppDelegate : UIResponder <UIApplicationDelegate>
{
    IBOutlet UIViewController* rootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
