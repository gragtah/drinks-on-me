#import "VenueCheckinsDataGetter.h"

@implementation VenueCheckinsDataGetter

@synthesize delegate;
@synthesize venueData;

- (void)getVenueData:( id)tableViewController venueId:(NSString *)venueId {
    self.delegate = tableViewController;
    venueData = [[NSMutableData alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/venues/%@/herenow?oauth_token=%@&v=%@", 
                           venueId, accessToken, [HelperFunctions dateAsString]];
//                           @"4d02a0b737036dcb2d7f04fb", accessToken, [HelperFunctions dateAsString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if(connection) {
        venueData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //there can be multiple responses per connection...
    //discard previously received data if another response comes afterwards
    [venueData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [venueData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //once this method is invoked, "friendData" contains the completed result
    NSString *dataContent = [[NSString alloc] initWithData:venueData encoding:NSASCIIStringEncoding];
    //NSLog(@"data request COMPLETE: %@", dataContent);
    
    [delegate didFinishVenueCheckinLoading:dataContent];
}

@end
