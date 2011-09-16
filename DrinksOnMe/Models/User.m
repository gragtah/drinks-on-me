#import "User.h"

@implementation User

@synthesize delegate;
@synthesize userData;

@synthesize venmoID;
@synthesize foursquareID;
@synthesize firstName;
@synthesize lastName;
@synthesize foursquareEmail;
@synthesize status;
@synthesize venueName;
@synthesize venueID;

@synthesize photoURL;
@synthesize friends;

- (User *)init {
    self = [super init];
    firstName = @"";
    lastName = @"";
    status = @"";
    venueName = @"";
    return self;
}

# pragma mark - User

- (void)getUserData:(id)tableViewController {
    self.delegate = tableViewController;
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
    [delegate didFinishUserLoading:dataContent];
}


@end

