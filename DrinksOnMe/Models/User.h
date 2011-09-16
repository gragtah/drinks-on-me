#import <Foundation/Foundation.h>
#import "../Supporting Files/HelperFunctions.h"

@protocol UserDelegate;

@interface User : NSURLConnection <NSURLConnectionDelegate> {
    NSString *venmoID;
    NSString *foursquareID;
    NSString *firstName;
    NSString *lastName;
    NSString *foursquareEmail;
    NSString *photoURL;
    
    NSArray *friends;
}

@property (assign, nonatomic) id <UserDelegate> delegate;
@property (strong, nonatomic) NSMutableData *userData;

@property (strong, nonatomic) NSString *venmoID;
@property (strong, nonatomic) NSString *foursquareID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *foursquareEmail;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *venueName;
@property (strong, nonatomic) NSString *venueID;

@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSArray *friends;

- (void)getUserData:(id)tableViewController;

@end

@protocol UserDelegate <NSObject>

@required
- (void)didFinishUserLoading:(NSString *)jsonData;

@end
