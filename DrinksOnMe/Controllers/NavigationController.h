#import <UIKit/UIKit.h>
#import <Venmo/Venmo.h>
#import "FriendsViewController.h"
#import "VenueViewController.h"
#import "LoginViewController.h"

@interface NavigationController : UINavigationController <LoginViewControllerDelegate, UserDelegate>

@property (strong, nonatomic) FriendsViewController *friendsViewController;
@property (strong, nonatomic) VenueViewController *venueViewController;
@property (strong, nonatomic) User *mainUser;
@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) UISegmentedControl *friendsVenue;
@property (strong, nonatomic) UIBarButtonItem *logoutButton;

@end
