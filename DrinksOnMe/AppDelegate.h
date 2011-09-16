#import <UIKit/UIKit.h>
#import "Venmo/Venmo.h"

@class NavigationController; //forward class declaration

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NavigationController *navigationController;
@property (strong, nonatomic) VenmoClient *venmoClient;

@end
