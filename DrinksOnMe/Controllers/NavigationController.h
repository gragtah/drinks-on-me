#import <UIKit/UIKit.h>
#import "FriendsViewController.h"
#import "VenueViewController.h"
#import "LoginViewController.h"
#import "Venmo/Venmo.h"

@interface NavigationController : UINavigationController <LoginViewControllerDelegate, UserDelegate>

@property (strong, nonatomic) FriendsViewController *friendsViewController;
@property (strong, nonatomic) VenueViewController *venueViewController;
@property (strong, nonatomic) User *mainUser;
@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) UISegmentedControl *friendsVenue;
@property (strong, nonatomic) UIBarButtonItem *logoutButton;

@end

//https://venmo.com/api/v2/user_find?client_id=1001&client_secret=CacCV7623Kd9tdH5PyGZXbnGZxkVTzdR&foursquare_ids=690,8687306" -b "VV=64;"