# Singly SDK #

A simple iOS SDK for accessing Singly.

## Getting Started ##

The first thing you should do is [register an application](https://singly.com/apps) at Singly.  In your
application settings you need to get your client id and client secret.  We'll need
to put this into our new program for logging in.

Now that we're ready we can either start a new iOS application or use an existing one.
In order to use the SDK make sure that you setup your header search path to point to the
`SinglySDK` directory and that your project includes the libSinglySDK.a library.


To login, create a ViewController with a SinglyLoginDelgate
```objective-c
#import "SinglySDK.h"

@interface SinglyViewController : UIViewController<SinglyLoginDelegate>
```

Then present a SinglyLoginViewController for a user to enter credentials

```objective-c
SinglyLogInViewController *loginVC = [[SinglyLogInViewController alloc] initWithService:kSinglyServiceInstagram];
loginVC.delegate = self;

[self presentModalViewController:loginVC animated:YES];

```
The service that you define can be any string of the services that Singly supports,
but we have these defined as constants for you in the SinglySDK.h.

An example implementation of the `SinglyLoginDelegate` is:

```objective-c
#pragma mark - SinglyLoginDelegate

-(void)singlyDidLogInForService:(NSString *)service;
{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)singlyErrorLoggingInToService:(NSString *)service withError:(NSError *)error;
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self dismissModalViewControllerAnimated:YES];
}

```

Once we have a valid session we can start making API requests.  We can make
GET, POST or any method requests using the `SinglyAPIRequest`.  The request is only
a description of the request that we are going to make, to actually execute the 
request we use our session and one of the `requestAPI:` methods.  An example
that requests the profiles list and is using blocks to handle the result is:

```objective-c
[session requestAPI:[SinglyAPIRequest apiRequestForEndpoint:@"profiles" withParameters:nil] withCompletionHandler:^(NSError *error, id json) {
    NSLog(@"The profiles result is: %@", json);
}];
```
Add Singly ios sdk as a submodule
git submodule add git://github.com/bcbroussard/iOS-SDK.git SinglySDK

or

Download a zipped copy and extract to your project's top directory

Run *git submodule update* from the terminal inside the SinglySDK directory to download MKNetworkKit and SSKeychain project dependencies

Open your Project Settings and goto Build Settings -> Header Search Paths
Add "${SRCROOT}/../" including the quotes

Add 
-ObjC -all_load 
to the Other Linker Flags build setting

In AppDelegate didFinishLaunchingWithOptions add:

SinglyClient *singlyClient = [SinglyClient sharedClient];
singlyClient.clientId = @"<MY_ID>";
singlyClient.clientSecret = @"<MY_SECRET>";


That's the basics and enough to get rolling!

Check if logged in and start the login process:

    if(![[SinglyClient sharedClient] isLoggedIn])
    {
        SinglyLogInViewController *_loginVC = [[SinglyLogInViewController alloc] initWithService:kSinglyServiceInstagram];
        [self presentModalViewController:_loginVC animated:YES];
        
    }
    
    
Make a request to Singly API

        [SinglyClient requestInstagram:@"self"//requestFacebook:@"profiles" 
                        withParameters:nil                                   
                    andCompletionBlock:^(id jsonResponse)
         {
             NSLog(@"Got a dictionary or array result:\n%@", jsonResponse);
             
         }onError:^(NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
         
The SinglyClient class holds all your relevant information after setting it once in the AppDelegate