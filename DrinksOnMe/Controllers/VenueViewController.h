#import <UIKit/UIKit.h>
#import "../Views/FriendsCell.h"
#import "../Models/User.h"
#import "../Models/VenueCheckinsDataGetter.h"
#import "../SBJson_Classes/SBJson.h"
#import <Venmo/Venmo.h>

@interface VenueViewController : UITableViewController <UserDelegate, VenueCheckinsDataGetterDelegate, UserDetailDelegate>

@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) VenmoTransaction *venmoTransaction;

@property (strong, nonatomic) User *mainUser;
@property (strong, nonatomic) VenueCheckinsDataGetter *venueCheckinsDataGetter;

@property (strong, nonatomic) NSMutableArray *checkedInUsers;

@end
