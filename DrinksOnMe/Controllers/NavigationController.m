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
//    [friendsVenue setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:13.0f]
//                                                                     forKey:UITextAttributeFont] 
//                                forState:UIControlStateNormal];
    friendsVenue.frame = CGRectMake(0.0f, 0.0f, 160.0f, 27.0f);
    friendsVenue.segmentedControlStyle = UISegmentedControlStyleBar;
    [friendsVenue setWidth:0.0f forSegmentAtIndex:1];
    friendsVenue.apportionsSegmentWidthsByContent = YES;
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

- (void) viewChanged:(UISegmentedControl *)sender {
    if([sender selectedSegmentIndex] == 0) {
        if(!friendsViewController) {
            NSLog(@"loading friends view controller");
            FriendsViewController *friendsVC = [[FriendsViewController alloc] init];
            self.friendsViewController = friendsVC;
            friendsVC.navigationItem.titleView = friendsVenue;
            friendsVC.navigationItem.leftBarButtonItem = logoutButton;
            friendsVC.venmoClient = self.venmoClient;
            
            self.mainUser = [[User alloc] init];
            VenueViewController *venueVC = [[VenueViewController alloc] init];
            venueVC.mainUser = mainUser;
            self.venueViewController = venueVC;
            [mainUser getUserData:self];
        }
        self.viewControllers = [NSArray arrayWithObject:friendsViewController];
    } else {
        if(venueViewController) {
            NSLog(@"loading venue view controller");
            venueViewController.navigationItem.titleView = friendsVenue;
            venueViewController.navigationItem.leftBarButtonItem = logoutButton;
            venueViewController.venmoClient = self.venmoClient;
        }
        self.viewControllers = [NSArray arrayWithObject:venueViewController];
    }
}

- (void)didLogin {
    [friendsVenue setSelectedSegmentIndex:0];
    [self viewChanged:friendsVenue];
}

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

- (void)didFinishUserLoading:(NSString *)jsonData {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonData error:&error];
    NSArray *userJSON = [[jsonObjects valueForKey:@"response"] valueForKey:@"user"];
    NSObject *venue = [[[[userJSON valueForKey:@"checkins"] valueForKey:@"items"] 
                        objectAtIndex:0] valueForKey:@"venue"];
    
    mainUser.foursquareID = [userJSON valueForKey:@"id"];
    mainUser.venueID = [venue valueForKey:@"id"];
    mainUser.venueName = [venue valueForKey:@"name"];
    
    NSString *titleText = ([mainUser.venueName length]>8 ? 
                           [NSString stringWithFormat:@"%@...", [mainUser.venueName substringToIndex:8]] 
                           : mainUser.venueName);
    [friendsVenue setTitle:[NSString stringWithFormat:@"@%@", titleText] 
         forSegmentAtIndex:1];
}

@end
