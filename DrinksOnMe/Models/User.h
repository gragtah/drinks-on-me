#import <Foundation/Foundation.h>
#import "UserDetailDataGetter.h"
#import "HelperFunctions.h"
#import "VenmoUsernameGetter.h"

@protocol UserDelegate;
@protocol UserDetailDelegate;

@interface User : NSURLConnection <NSURLConnectionDelegate, UserDetailDataGetterDelegate, VenmoUsernameGetterDelegate>

@property (assign, nonatomic) id <UserDelegate> navigationControllerDelegate;
@property (assign, nonatomic) id <UserDetailDelegate> userDetailDelegate;
@property (strong, nonatomic) UserDetailDataGetter *userDetailGetter;
@property (strong, nonatomic) VenmoUsernameGetter *venmoUsernameGetter;

@property (strong, nonatomic) NSMutableData *userData;

@property (strong, nonatomic) NSString *venmoName;
@property (strong, nonatomic) NSString *foursquareID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *foursquareEmail;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *venueName;
@property (strong, nonatomic) NSString *venueID;

@property (strong, nonatomic) NSString *photoURLString;
@property (strong, nonatomic) NSArray *friends;

- (void)getUserData:(id)tableViewController;
- (void)getUserDetailData:(id)theUserDetailDelegate;

@end

@protocol UserDelegate <NSObject>

@required
- (void)didFinishUserLoading:(NSString *)jsonData;

@end

@protocol UserDetailDelegate <NSObject>

@required
- (void)didFinishUserDetailLoading;

@end
