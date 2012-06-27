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
        firstName = @"";
        lastName = @"";
    }
    return self;
}

# pragma mark - User

/**
 * Gets the main user's data.
 */
- (void)getUserData:(id)tableViewController {
    self.navigationControllerDelegate = tableViewController;
    userData = [[NSMutableData alloc] init];
    
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
    if(connection) {
        userData = [NSMutableData data];
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
    NSError *error = nil;
    NSArray *foursquareJson = [jsonParser objectWithString:userFoursquareJson error:&error];
    NSArray *venmoJson  = [jsonParser objectWithString:userVenmoJson error:&error];
    
    NSObject *fsqContact = [[[foursquareJson valueForKey:@"response"] valueForKey:@"user"] 
                            valueForKey:@"contact"];
    NSObject *fsqCheckin = [[[[[foursquareJson valueForKey:@"response"] valueForKey:@"user"] 
                              valueForKey:@"checkins"] valueForKey:@"items"] objectAtIndex:0];
    
    foursquareEmail = [fsqContact valueForKey:@"email"];
    phone = [fsqContact valueForKey:@"phone"];
    twitter = [fsqContact valueForKey:@"twitter"];
    facebookID = [fsqContact valueForKey:@"facebook"];

    status = [fsqCheckin valueForKey:@"shout"];
    venueName = [[fsqCheckin valueForKey:@"venue"] valueForKey:@"name"];
    venueID = [[fsqCheckin valueForKey:@"venue"] valueForKey:@"id"];
    
    NSArray *venmoContact = [venmoJson valueForKey:@"data"];
    if(venmoContact.count > 0) {
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
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *venmoJson = [jsonParser objectWithString:jsonData error:&error];
    NSArray *venmoContact = [venmoJson valueForKey:@"data"];

    // if a venmo username was able to be retrieved, use it!
    if(venmoContact.count > 0) {
        venmoName = [[venmoContact objectAtIndex:0] valueForKey:@"username"];
    }
    
    [userDetailDelegate didFinishUserDetailLoading];
}

@end
