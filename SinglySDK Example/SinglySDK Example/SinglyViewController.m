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


    if([[SinglyClient sharedClient] isLoggedIn])
    {
        //We're already loggedin!
        
        [SinglyClient requestInstagram:@"self"
                        withParameters:nil                                   
                    andCompletionBlock:^(id jsonResponse)
         {
             if([jsonResponse isKindOfClass:[NSDictionary class]])
             {
                 NSLog(@"Got a dicationary result:\n%@", (NSDictionary *)jsonResponse);
             }
             else 
             {
                 //NSArray
                 NSLog(@"Got array result:\n%@", (NSArray *)jsonResponse);
             }

             
         }onError:^(NSError *error)
         {
             NSLog(@"Error: %@", error);
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

#pragma mark - SinglyLoginDelegate

-(void)singlyDidLogInForService:(NSString *)service;
{
    [self dismissModalViewControllerAnimated:YES];
    _loginVC = nil;
}
-(void)singlyErrorLoggingInToService:(NSString *)service withError:(NSError *)error;
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self dismissModalViewControllerAnimated:YES];
    _loginVC = nil;
}

- (IBAction)loginCLick:(id)sender {
    SinglyLogInViewController *loginVC = [[SinglyLogInViewController alloc] initWithService:kSinglyServiceInstagram];
    loginVC.delegate = self;
    
    [self presentModalViewController:loginVC animated:YES];
}
@end
