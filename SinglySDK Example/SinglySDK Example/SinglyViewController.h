//
//  SinglyViewController.h
//  SinglySDK Example
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglySDK.h"

@interface SinglyViewController : UIViewController<SinglyLoginDelegate>
- (IBAction)loginCLick:(id)sender;

@end
