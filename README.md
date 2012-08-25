Currently this file holds the project goals for this repo, once the initial pass is complete this will turn into a normal README.

**Goals:**
* A __simple__ API targeted at iOS developers with only 1-2 years experience in the field
  * The developer does not need to understand the OAuth flow
  * The developer does not need to manage the access token
  * The developer can easily post back out to a network
  * The developer has full access to the singly API

**Implementation:**
Configuration of this object will be achieved with a SinglyLoginViewController which will guide the user
through the login experience, both Singly itself and other networks.

Add Singly ios sdk as a submodule
git submodule add git://github.com/bcbroussard/iOS-SDK.git SinglySDK

or

Download a zipped copy and extract to your project's top directory

Run git submodule update to download MKNetworkKit dependency

Open your Project Settings and goto Build Settings -> Header Search Paths
Add "${SRCROOT}/../" including the quotes

Add 
-ObjC -all_load 
to the Other Linker Flags build setting

In AppDelegate didFinishLaunchingWithOptions add:

SinglyClient *singlyClient = [SinglyClient sharedClient];
singlyClient.clientId = @"<MY_ID>";
singlyClient.clientSecret = @"<MY_SECRET>";


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