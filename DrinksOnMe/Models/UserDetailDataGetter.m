#import "UserDetailDataGetter.h"
#import "AppConstants.h"

@interface UserDetailDataGetter () //this is a class extension to create private methods

@property (assign, nonatomic) BOOL gotFoursquareData;

- (void)getVenmoData;

@end 

@implementation UserDetailDataGetter

@synthesize delegate;
@synthesize detailData;
@synthesize foursquareId;
@synthesize userFoursquareJson;
@synthesize gotFoursquareData;

# pragma mark - Getting the user's detailed information, 4sq first then Venmo

/**
 * Looks up the contact information of an individual 4sq user.
 */
- (void)getUserDetailData:(id)user foursquareId:(NSString *)theFoursquareId {
    self.delegate = user;
    self.foursquareId = theFoursquareId;
    detailData = [[NSMutableData alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/users/%@?oauth_token=%@&v=%@", 
                           self.foursquareId, accessToken, [HelperFunctions dateAsString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if(connection) {
        detailData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

/**
 * Looks up the venmo username of an individual 4sq user, based off that user's public contact info.
 */
- (void)getVenmoData {
    NSString *urlString = [NSString stringWithFormat:
                           @"https://venmo.com/api/v2/user_find?client_id=%@&client_secret=%@&foursquare_ids=%@", 
                           venmoAppId, venmoAppSecret, foursquareId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if(connection) {
        detailData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [detailData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [detailData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *dataContent = [[NSString alloc] initWithData:detailData encoding:NSASCIIStringEncoding];
    
    // once the 4sq contact info and venmo username have been looked up, return to delegate
    if(!gotFoursquareData) {
        [self getVenmoData];
        userFoursquareJson = dataContent;
        gotFoursquareData = true;
    } else {
        [delegate didFinishUserDetailLoading:userFoursquareJson 
                               userVenmoJson:dataContent];
        gotFoursquareData = false;
    }
}

@end
