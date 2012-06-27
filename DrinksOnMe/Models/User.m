#import "User.h"
#import "SBJson.h"

@implementation User

@synthesize navigationControllerDelegate;
@synthesize userDetailDelegate;
@synthesize userDetailGetter;
@synthesize venmoUsernameGetter;
@synthesize userData;

@synthesize venmoName;
@synthesize foursquareID;
@synthesize firstName;
@synthesize lastName;
@synthesize foursquareEmail;
@synthesize phone;
@synthesize twitter;
@synthesize facebookID;
@synthesize status;
@synthesize venueName;
@synthesize venueID;

@synthesize photoURLString;
@synthesize friends;

- (id)init {
    if (self = [super init]) {
        self.firstName = @"";
        self.lastName = @"";
    }
    return self;
}

# pragma mark - User

/**
 * Gets the main user's data.
 */
- (void)getUserData:(id)tableViewController {
    self.navigationControllerDelegate = tableViewController;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/users/self?oauth_token=%@&v=%@", 
                           accessToken, [HelperFunctions dateAsString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if (connection) {
        self.userData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

/**
 * Gets the non-main user's detailed information; like the email, phone, twitter, and facebook.
 */
- (void)getUserDetailData:(id)theUserDetailDelegate {
    self.userDetailDelegate = theUserDetailDelegate;
    self.userDetailGetter = [[UserDetailDataGetter alloc] init];
    [userDetailGetter getUserDetailData:self foursquareId:foursquareID];
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [userData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [userData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *dataContent = [[NSString alloc] initWithData:userData encoding:NSASCIIStringEncoding];
    [navigationControllerDelegate didFinishUserLoading:dataContent];
}

#pragma mark - UserDetailDataGetterDelegate

/**
 * Gets the detailed information about the user from the 4sq api
 *  If venmo username can be retrieved from 4sq username, use it. Otherwise search for it
 *  based on the 4sq contact information.
 */
- (void)didFinishUserDetailLoading:(NSString *)userFoursquareJson 
                     userVenmoJson:(NSString *)userVenmoJson {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSArray *foursquareJson = [jsonParser objectWithString:userFoursquareJson error:NULL];
    NSArray *venmoJson  = [jsonParser objectWithString:userVenmoJson error:NULL];

    NSDictionary *userDictionary = [foursquareJson valueForKeyPath:@"response.user"];
    NSDictionary *fsqContactDictionary = [userDictionary objectForKey:@"contact"];
    NSDictionary *fsqCheckinDictionary = [[userDictionary valueForKeyPath:@"checkins.items"] objectAtIndex:0];
    
    self.foursquareEmail = [fsqContactDictionary objectForKey:@"email"];
    self.phone = [fsqContactDictionary objectForKey:@"phone"];
    self.twitter = [fsqContactDictionary objectForKey:@"twitter"];
    self.facebookID = [fsqContactDictionary objectForKey:@"facebook"];

    self.status = [fsqCheckinDictionary objectForKey:@"shout"];
    NSDictionary *fsqVenmue = [fsqCheckinDictionary objectForKey:@"venue"];
    self.venueName = [fsqVenmue objectForKey:@"name"];
    self.venueID = [fsqVenmue valueForKey:@"id"];
    
    NSArray *venmoContact = [venmoJson valueForKey:@"data"];
    if ([venmoContact count] > 0) {
        venmoName = [[venmoContact valueForKey:@"username"] objectAtIndex:0];
    }
//    NSLog(@"Foursquare user's credentials: %@, %@, %@, %@, %@", 
//          firstName, facebookID, foursquareEmail, phone, twitter);
    
    // if a venmo username was retrieved, return to view controller. 
    if (venmoName) {
        [userDetailDelegate didFinishUserDetailLoading];
    } 
    else if (facebookID || foursquareEmail || phone || twitter) {
        //else search for it on venmo servers
        venmoUsernameGetter = [[VenmoUsernameGetter alloc] init];
        [venmoUsernameGetter getVenmoUsernameData:self
                                       facebookId:self.facebookID
                                            email:self.foursquareEmail
                                            phone:self.phone
                                          twitter:self.twitter];
    }
}

#pragma mark - VenmoUSernameGetterDelegate

/**
 * Called after the venmo username was looked up based on the facebook id, email, twitter, or phone.
 *  Those items of contact information were retrieved from the 4sq api.
 */
- (void)didFinishVenmoUsernameLoading:(NSString *)jsonData {    
    NSArray *venmoContact = [[[[SBJsonParser alloc] init] objectWithString:jsonData error:NULL]
                             objectForKey:@"data"];

    // if a venmo username was able to be retrieved, use it!
    if ([venmoContact count]) {
        self.venmoName = [[venmoContact objectAtIndex:0] objectForKey:@"username"];
    }

    [userDetailDelegate didFinishUserDetailLoading];
}

@end
