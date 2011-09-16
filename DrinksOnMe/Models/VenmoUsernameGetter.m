#import "VenmoUsernameGetter.h"
#import "AppConstants.h"

@implementation VenmoUsernameGetter

@synthesize delegate;
@synthesize venmoData;

- (void)getVenmoUsernameData:(id)tableViewController 
                  facebookId:(NSString *)facebookId 
                       email:(NSString *)email 
                       phone:(NSString *)phone 
                     twitter:(NSString *)twitter {
    
    self.delegate = tableViewController;
    venmoData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://venmo.com/api/v2/user_find?client_id=%@&client_secret=%@&facebook_ids=%@&emails=%@&phone_numbers=%@&twitter_screen_names=%@", 
                           venmoAppId, venmoAppSecret, 
                           facebookId?facebookId:@"", 
                           email?email:@"", 
                           phone?phone:@"", 
                           twitter?twitter:@""];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                            timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                  delegate:self];
    if(connection) {
        venmoData = [NSMutableData data];
    } else {
        NSLog(@"connection failed");
    }
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //there can be multiple responses per connection...
    //discard previously received data if another response comes afterwards
    [venmoData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [venmoData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CONNECTION FAILED: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *dataContent = [[NSString alloc] initWithData:venmoData encoding:NSASCIIStringEncoding];
    NSLog(@"VENMO USERNAME RECEIVED: %@", dataContent);
    [delegate didFinishVenmoUsernameLoading:dataContent];
}

@end
