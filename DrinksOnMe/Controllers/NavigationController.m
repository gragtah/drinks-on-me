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
    [friendsVenue setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:12.0f]
                                                                     forKey:UITextAttributeFont] 
                                forState:UIControlStateNormal];
    friendsVenue.frame = CGRectMake(0.0f, 0.0f, 160.0f, 30.0f);
    [friendsVenue addTarget:self 
                     action:@selector(viewChanged:) 
           forControlEvents:UIControlEventValueChanged];
    friendsVenue.selectedSegmentIndex = 0;
    
    // Create the logout button
    logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
                                                    style:UIBarButtonItemStyleDone 
                                                   target:self 
                                                   action:@selector(logout)];
    
    // Create the friends view controller (lazily load the venue view when it's selected)
//    FriendsViewController *friendsVC = [[FriendsViewController alloc] init];
//    self.friendsViewController = friendsVC;
//    self.viewControllers = [NSArray arrayWithObjects:friendsVC, nil];
    
    // Add top nav bar items
//    friendsVC.navigationItem.titleView = friendsVenue;
//    friendsVC.navigationItem.rightBarButtonItem = logoutButton;
}

- (void) viewChanged:(UISegmentedControl *)sender {
    if([sender selectedSegmentIndex] == 0) {
        if(friendsViewController == nil) {
            NSLog(@"loading friends view controller");
            FriendsViewController *friendsVC = [[FriendsViewController alloc] init];
            self.friendsViewController = friendsVC;
            friendsVC.navigationItem.titleView = friendsVenue;
            friendsVC.navigationItem.leftBarButtonItem = logoutButton;
            friendsVC.venmoClient = self.venmoClient;
        }
        self.viewControllers = [NSArray arrayWithObjects:friendsViewController, nil];
    } else {
        if(venueViewController == nil) {
            NSLog(@"loading venue view controller");
            VenueViewController *venueVC = [[VenueViewController alloc] init];
            self.venueViewController = venueVC;
            venueVC.navigationItem.titleView = friendsVenue;
            venueVC.navigationItem.leftBarButtonItem = logoutButton;
            venueVC.venmoClient = self.venmoClient;
        }
        self.viewControllers = [NSArray arrayWithObjects:venueViewController, nil];
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
}

@end

/*
response: {
user: {
    id: "3789071"
firstName: "Matt"
lastName: "Di Pasquale"
photo: "https://playfoursquare.s3.amazonaws.com/userpix_thumbs/V5CPVTZZ0PECUVPF.jpg"
gender: "male"
homeCity: "Westport, CT"
relationship: "friend"
type: "user"
pings: true
contact: {
phone: "6178940859"
email: "liveloveprosper@gmail.com"
twitter: "mattdipasquale"
facebook: "514417"
}
 */