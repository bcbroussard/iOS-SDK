//
//  SinglyViewController.m
//  SinglySDK Example
//
//  Created by Thomas Muldowney on 8/22/12.
//  Copyright (c) 2012 Singly. All rights reserved.
//

#import "SinglyViewController.h"
@interface SinglyViewController ()
{
    SinglyLogInViewController* _loginVC;
}
@end

@implementation SinglyViewController

-(void)viewWillAppear:(BOOL)animated
{
    DLog(@"View will appear for app");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"Session account is %@ and access token is %@", [SinglyClient sharedClient].accountId, [SinglyClient sharedClient].accessToken);

    if(![[SinglyClient sharedClient] isLoggedIn])
    {
        _loginVC = [[SinglyLogInViewController alloc] initWithService:kSinglyServiceInstagram];
        [self presentModalViewController:_loginVC animated:YES];
        
    } else {
        DLog(@"We're already done!");
        
        [SinglyClient requestInstagram:@"self"//requestFacebook:@"profiles" 
                        withParameters:nil                                   
                    andCompletionBlock:^(id jsonResponse)
         {
             DLog(@"Got a result:\n%@", jsonResponse);
             
         }onError:^(NSError *error)
         {
             DLog(@"Error: %@", error);
         }];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
