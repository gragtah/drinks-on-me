#import "User.h"
#import "SBJson.h"

@implementation User

@synthesize navigationControllerDelegate;
@synthesize userDetailDelegate;
@synthesize userDetailGetter;
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

@synthesize photoURL;
@synthesize friends;

- (User *)init {
    self = [super init];
    firstName = @"";
    lastName = @"";
    return self;
}

# pragma mark - User

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

- (void)getUserDetailData:(id)theUserDetailDelegate {
    self.userDetailDelegate = theUserDetailDelegate;
    self.userDetailGetter = [[UserDetailDataGetter alloc] init];
    [userDetailGetter getUserDetailData:self foursquareId:foursquareID];
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //there can be multiple responses per connection...
    //discard previously received data if another response comes afterwards
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

- (void)didFinishUserDetailLoading:(NSString *)userFoursquareJson 
                     userVenmoJson:(NSString *)userVenmoJson {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *foursquareJson = [jsonParser objectWithString:userFoursquareJson error:&error];
    NSArray *venmoJson  = [jsonParser objectWithString:userVenmoJson error:&error];
    
    NSObject *fsqContact = [[[foursquareJson valueForKey:@"response"] valueForKey:@"user"] valueForKey:@"contact"];
    NSObject *fsqCheckin = [[[[[foursquareJson valueForKey:@"response"] valueForKey:@"user"] valueForKey:@"checkins"] valueForKey:@"items"] objectAtIndex:0];
    
    foursquareEmail = [[fsqContact valueForKey:@"contact"] valueForKey:@"email"];
    phone = [[fsqContact valueForKey:@"contact"] valueForKey:@"phone"];
    twitter = [[fsqContact valueForKey:@"contact"] valueForKey:@"twitter"];
    facebookID = [[fsqContact valueForKey:@"contact"] valueForKey:@"facebook"];

    status = [fsqCheckin valueForKey:@"shout"];
    venueName = [[fsqCheckin valueForKey:@"venue"] valueForKey:@"name"];
    venueID = [[fsqCheckin valueForKey:@"venue"] valueForKey:@"id"];
    
    NSArray *venmoContact = [venmoJson valueForKey:@"data"];
    if(venmoContact.count > 0) {
        venmoName = [[venmoContact valueForKey:@"username"] objectAtIndex:0];
    }
    
    [userDetailDelegate didFinishUserDetailLoading];
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
        }
    }
 
 
 {"data": 
    [{"username": "kortina", "foursquare_id": "690"}, 
     {"username": "graham", "foursquare_id": "8687306"}
 ]}
 
 */