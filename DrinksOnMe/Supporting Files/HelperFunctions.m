#import "HelperFunctions.h"

@implementation HelperFunctions

+ (NSString *)dateAsString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYYMMDD"];
    return [format stringFromDate:[NSDate date]];
}

+ (void)openVenmoAction:(UIViewController *)viewController
            venmoClient:(VenmoClient *)venmoClient 
       venmoTransaction:(VenmoTransaction *)venmoTransaction {
    
    VenmoViewController *venmoViewController = [venmoClient viewControllerWithTransaction:
                                                venmoTransaction forceWeb:NO];
    if (venmoViewController) {
        [viewController presentModalViewController:venmoViewController animated:YES];
    }
}

+ (void)openWebAction:(UIViewController *)viewController
          venmoClient:(VenmoClient *)venmoClient 
     venmoTransaction:(VenmoTransaction *)venmoTransaction {
    VenmoViewController *venmoViewController = [venmoClient viewControllerWithTransaction:
                                                venmoTransaction forceWeb:YES];
    [viewController presentModalViewController:venmoViewController animated:YES];
}

@end