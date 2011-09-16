#import "FriendDataGetter.h"

@implementation FriendDataGetter

@synthesize delegate;
@synthesize friendData;
@synthesize user;

# pragma mark - Getting the user's 4sq data

- (void)getFriendData:(id)tableViewController {
    self.delegate = tableViewController;
    friendData = [[NSMutableData alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/users/self/friends?oauth_token=%@&v=%@", 
                           accessToken, [HelperFunctions dateAsString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if(connection) {
        friendData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //there can be multiple responses per connection...
    //discard previously received data if another response comes afterwards
    [friendData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [friendData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //once this method is invoked, "friendData" contains the completed result
    NSString *dataContent = [[NSString alloc] initWithData:friendData encoding:NSASCIIStringEncoding];
    //NSLog(@"data request COMPLETE: %@", dataContent);

    [delegate didFinishFriendLoading:dataContent];
}

@end
