#import <UIKit/UIKit.h>
#import "../Views/FriendsCell.h"
#import "../Models/User.h"
#import "../Models/FriendDataGetter.h"
#import "../SBJson_Classes/SBJson.h"
#import <Venmo/Venmo.h>

@interface FriendsViewController : UITableViewController <FriendDataGetterDelegate, VenmoClientDelegate>

@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) VenmoTransaction *venmoTransaction;

@property (strong, nonatomic) FriendDataGetter *friendDataGetter;

@property (strong, nonatomic) NSMutableArray *friendUsers;

@end
