#import <UIKit/UIKit.h>
#import <Venmo/Venmo.h>

@class NavigationController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, VenmoClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NavigationController *navigationController;
@property (strong, nonatomic) VenmoClient *venmoClient;

@end
