#import "AppDelegate.h"
#import "NavigationController.h"
#import "LoginViewController.h"

static NSString *const venmoAppId      = @"";
static NSString *const venmoLocalAppId = @"";
static NSString *const venmoAppSecret  = @"";

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize venmoClient;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create the Venmo Client object
    self.venmoClient = [VenmoClient clientWithAppId:venmoAppId 
                                        secret:venmoAppSecret
                                       localId:venmoLocalAppId];
    venmoClient.delegate = self;
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    self.navigationController = [[NavigationController alloc] 
                                 initWithRootViewController:loginVC];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"openURL: %@", url);
    return [venmoClient openURL:url completionHandler:^(VenmoTransaction *transaction, NSError *error) {
        if (transaction) {
            NSString *success = (transaction.success ? @"Success" : @"Failure");
            NSString *title = [@"Transaction " stringByAppendingString:success];
            NSString *message = [@"payment_id: " stringByAppendingFormat:@"%i. %i %@ %@ (%i) $%@ %@",
                                 transaction.id,
                                 transaction.fromUserId,
                                 transaction.typeStringPast,
                                 transaction.toUserHandle,
                                 transaction.toUserId,
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

@end
