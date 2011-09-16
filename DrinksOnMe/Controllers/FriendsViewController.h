#import <UIKit/UIKit.h>
#import <Venmo/Venmo.h>

#import "FriendsCell.h"
#import "User.h"
#import "FriendDataGetter.h"


@interface FriendsViewController : UITableViewController <FriendDataGetterDelegate, UserDetailDelegate>

@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) VenmoTransaction *venmoTransaction;

@property (strong, nonatomic) FriendDataGetter *friendDataGetter;

@property (strong, nonatomic) NSMutableArray *friendUsers;

@end
