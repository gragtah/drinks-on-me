#import <Foundation/Foundation.h>
#import "../Supporting Files/HelperFunctions.h"

@protocol VenmoUsernameGetterDelegate;

@interface VenmoUsernameGetter : NSURLConnection

@property (assign, nonatomic) id <VenmoUsernameGetterDelegate> delegate;
@property (strong, nonatomic) NSMutableData *venmoData;

- (void)getVenmoUsernameData:(id)tableViewController 
                  facebookId:(NSString *)facebookId 
                       email:(NSString *)email 
                       phone:(NSString *)phone 
                     twitter:(NSString *)twitter;

@end

@protocol VenmoUsernameGetterDelegate <NSObject>

@required
- (void)didFinishVenmoUsernameLoading:(NSString *)jsonData;

@end
