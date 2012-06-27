#import <Foundation/Foundation.h>
#import "User.h"
#import "HelperFunctions.h"

@protocol FriendDataGetterDelegate;

@interface FriendDataGetter : NSURLConnection <NSURLConnectionDelegate>

@property (assign, nonatomic) id <FriendDataGetterDelegate> delegate;
@property (strong, nonatomic) NSMutableData *friendData;
@property (strong, nonatomic) User *user;

- (void)getFriendData:(id)tableViewController;

@end

//protocol for the TableViewControllers to conform to once the data has finished loading
@protocol FriendDataGetterDelegate <NSObject>

@required

- (void)didFinishFriendLoading:(NSString *)jsonData;

@end