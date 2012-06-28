#import "AppDelegate.h"
#import "NavigationController.h"
#import "LoginViewController.h"
#import "Supporting Files/AppConstants.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize venmoClient;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Create the Venmo Client object (used for sending a payment through venmo)
    self.venmoClient = [VenmoClient clientWithAppId:venmoAppId 
                                             secret:venmoAppSecret
                                            localId:venmoLocalAppId];
    venmoClient.delegate = self;

//    // Test: Decode a signed_request into a VenmoTransaction object.
//    NSURL *url = [NSURL URLWithString:@"venmo1001://paycharge?signed_request=wdkVY03FSu-JohWnwFGgR3z8P44_3ZdS3nte2jD6KOA.W3sicGF5bWVudF9pZCI6IDU2NTIxMCwgIm5vdGUiOiAiSGF2ZSBhIGRyaW5rIG9uIG1lISIsICJhbW91bnQiOiAiNS4wMCIsICJzdWNjZXNzIjogMX1d"];
//    [venmoClient openURL:url completionHandler:^(VenmoTransaction *transaction, NSError *error) {
//        NSLog(@"transaction.transactionID: %@", transaction.transactionID);
//        NSLog(@"transaction.type: %i", transaction.type);
//        NSLog(@"transaction.fromUserID: %@", transaction.fromUserID);
//        NSLog(@"transaction.toUserID: %@", transaction.toUserID);
//        NSLog(@"transaction.amount: %f", transaction.amount);
//        NSLog(@"transaction.note: %@", transaction.note);
//        NSLog(@"transaction.success: %c", transaction.success);
//    }];

    // Create the view controller that enables logging in to foursquare
    LoginViewController *loginVC = [[LoginViewController alloc] init];

    navigationController = [[NavigationController alloc] initWithRootViewController:loginVC];
    navigationController.venmoClient = venmoClient;
    loginVC.delegate = navigationController;
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    
    // URL can be opened (aka, a payment was finished and DrinksOnMe is reopened) 
    //  the function below.
    if (launchOptions) {
        NSURL *openURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
            return YES;
        }
    }
    // URL can't be opened, so don't call the function below.
    return NO;
}

/**
 * Called when a payment finishes and the data is being sent back to DrinksOnMe.
 * - as an example, the data is displayed in a popup alert.
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"openURL: %@", url);
    return [venmoClient openURL:url completionHandler:^(VenmoTransaction *transaction, NSError *error) {
        if (transaction) {
            NSString *success = (transaction.success ? @"Success" : @"Failure");
            NSString *title = [@"Transaction " stringByAppendingString:success];
            NSString *message = [@"payment_id: " stringByAppendingFormat:@"%@. %@ %@ %@ (%@) $%@ %@",
                                 transaction.transactionID,
                                 transaction.fromUserID,
                                 transaction.typeStringPast,
                                 transaction.toUserHandle,
                                 transaction.toUserID,
                                 transaction.amountString,
                                 transaction.note];    
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else { // error
            NSLog(@"transaction error code: %i", error.code);
        }
    }];
}

/**
 * Called when the device is running less than iOS 5
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#pragma mark - VenmoClientDelegate

- (id)venmoClient:(VenmoClient *)client JSONObjectWithData:(NSData *)data {
    return nil;
}
#endif

@end
