#import <UIKit/UIKit.h>
#import "FriendsCell.h"
#import "User.h"
#import "VenueCheckinsDataGetter.h"
#import "SBJson.h"
#import <Venmo/Venmo.h>

@interface VenueViewController : UITableViewController <UserDelegate, VenueCheckinsDataGetterDelegate, UserDetailDelegate>

@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) VenmoTransaction *venmoTransaction;

@property (strong, nonatomic) User *mainUser;
@property (strong, nonatomic) VenueCheckinsDataGetter *venueCheckinsDataGetter;

@property (strong, nonatomic) NSMutableArray *checkedInUsers;

@end
