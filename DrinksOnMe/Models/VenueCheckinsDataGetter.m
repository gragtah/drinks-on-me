#import "VenueCheckinsDataGetter.h"

@implementation VenueCheckinsDataGetter

@synthesize delegate;
@synthesize venueData;

/**
 * Gets the users that are checked in at the current venue.
 */
- (void)getVenueData:( id)tableViewController venueId:(NSString *)venueId {
    self.delegate = tableViewController;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/venues/%@/herenow?oauth_token=%@&v=%@", 
                           venueId, accessToken, [HelperFunctions dateAsString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if (connection) {
        self.venueData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [venueData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [venueData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *dataContent = [[NSString alloc] initWithData:venueData encoding:NSASCIIStringEncoding];
    [delegate didFinishVenueCheckinLoading:dataContent];
}

@end
