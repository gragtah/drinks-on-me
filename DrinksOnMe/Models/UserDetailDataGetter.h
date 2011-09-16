#import <Foundation/Foundation.h>

#import "HelperFunctions.h"

@protocol UserDetailDataGetterDelegate;

@interface UserDetailDataGetter : NSURLConnection <NSURLConnectionDelegate>

@property (assign, nonatomic) id <UserDetailDataGetterDelegate> delegate;
@property (strong, nonatomic) NSMutableData *detailData;
@property (strong, nonatomic) NSString *foursquareId;
@property (strong, nonatomic) NSString *userFoursquareJson;

// Gets a foursquare user's more detailed data, like his current location, email address, shout (aka status), etc
- (void)getUserDetailData:(id)user foursquareId:(NSString *)foursquareId;

@end

@protocol UserDetailDataGetterDelegate <NSObject>

@required
- (void)didFinishUserDetailLoading:(NSString *)userFoursquareJson 
                     userVenmoJson:(NSString *)userVenmoJson;

@end