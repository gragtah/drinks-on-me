#import "NavigationController.h"

@interface NavigationController()
- (void) viewChanged:(UISegmentedControl *)sender;
@end

@implementation NavigationController

@synthesize friendsViewController;
@synthesize venueViewController;
@synthesize mainUser;
@synthesize venmoClient;
@synthesize friendsVenue;
@synthesize logoutButton;

- (void) viewDidUnload {
    venmoClient = nil;
    [super viewDidUnload];
}

- (void) viewDidLoad {

    // Create a segmented control
    friendsVenue = [[UISegmentedControl alloc] initWithItems:
                    [NSArray arrayWithObjects:@"Friends", @"@Venue", nil]];
    friendsVenue.frame = CGRectMake(0.0f, 0.0f, 160.0f, 27.0f);
    friendsVenue.segmentedControlStyle = UISegmentedControlStyleBar;
    [friendsVenue setWidth:0.0f forSegmentAtIndex:1];
    [friendsVenue addTarget:self
                     action:@selector(viewChanged:)
           forControlEvents:UIControlEventValueChanged];
    friendsVenue.selectedSegmentIndex = 0;

    // Create the logout button
    logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
                                                    style:UIBarButtonItemStyleDone 
                                                   target:self 
                                                   action:@selector(logout)];
}

/**
 * Handler when the segmented control changes selection.
 */
- (void) viewChanged:(UISegmentedControl *)sender {
    if ([sender selectedSegmentIndex] == 0) {
        //if it's the first time being shown, lazily load the table view controller
        if (!friendsViewController) {
            NSLog(@"loading friends view controller");
            FriendsViewController *friendsVC = [[FriendsViewController alloc] init];
            self.friendsViewController = friendsVC;
            friendsVC.navigationItem.titleView = friendsVenue;
            friendsVC.navigationItem.leftBarButtonItem = logoutButton;
            friendsVC.venmoClient = self.venmoClient;
            
            //the other view controller is allocated here so it's mainUser can be passed in
            self.mainUser = [[User alloc] init];
            VenueViewController *venueVC = [[VenueViewController alloc] init];
            venueVC.mainUser = mainUser;
            self.venueViewController = venueVC;
            [mainUser getUserData:self];
        }
        //display it
        self.viewControllers = [NSArray arrayWithObject:friendsViewController];
    } else {
        // load the rest of the venue table view controller
        if (venueViewController) {
            NSLog(@"loading venue view controller");
            venueViewController.navigationItem.titleView = friendsVenue;
            venueViewController.navigationItem.leftBarButtonItem = logoutButton;
            venueViewController.venmoClient = self.venmoClient;
        }
        // and then show it
        self.viewControllers = [NSArray arrayWithObject:venueViewController];
    }
}

/**
 * After the user successfully logs in to 4sq, show the table view
 */
- (void)didLogin {
    [friendsVenue setSelectedSegmentIndex:0];
    [self viewChanged:friendsVenue];
}

/**
 * If user logs out, nil out the two table view controllers and reshow the login view.
 */
- (void)logout {
    NSLog(@"logout clicked");
    
    // clear the access token from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"access_token"];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        [cookieJar deleteCookie:cookie];
    }
    
    // reshow the login view
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.delegate = self;
    self.viewControllers = [NSArray arrayWithObject:loginVC];

    // nil out the old view controllers
    friendsViewController = nil;
    venueViewController = nil;
}

#pragma mark - UserDelegate

/**
 * Search for the main user's 4sq information to set the title of the segmented control
 */
- (void)didFinishUserLoading:(NSString *)jsonData {
    NSDictionary *userDictionary = [[[[SBJsonParser alloc] init] objectWithString:jsonData error:NULL]
                                    valueForKeyPath:@"response.user"];
    NSDictionary *venueDictionary = [[[userDictionary valueForKeyPath:@"checkins.items"]
                                      objectAtIndex:0] objectForKey:@"venue"];

    mainUser.foursquareID = [userDictionary objectForKey:@"id"];
    mainUser.venueID = [venueDictionary objectForKey:@"id"];
    mainUser.venueName = [venueDictionary objectForKey:@"name"];

    // set the title
    NSString *titleText = ([mainUser.venueName length] > 8 ?
                           [NSString stringWithFormat:@"%@...", [mainUser.venueName substringToIndex:8]] 
                           : mainUser.venueName);
    [friendsVenue setTitle:[NSString stringWithFormat:@"@%@", titleText] 
         forSegmentAtIndex:1];
}

@end
