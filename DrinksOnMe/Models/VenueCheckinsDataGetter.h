#import <Foundation/Foundation.h>
#import "../Supporting Files/HelperFunctions.h"

@protocol VenueCheckinsDataGetterDelegate;

@interface VenueCheckinsDataGetter : NSURLConnection

@property (assign, nonatomic) id <VenueCheckinsDataGetterDelegate> delegate;
@property (strong, nonatomic) NSMutableData *venueData;

- (void)getVenueData:(id)tableViewController 
             venueId:(NSString *)venueId;

@end

@protocol VenueCheckinsDataGetterDelegate <NSObject>

@required
- (void)didFinishVenueCheckinLoading:(NSString *)jsonData;

@end
