#import "FriendsViewController.h"
#import "../Views/FriendsCell.h"
#import "SBJson.h"

@implementation FriendsViewController

@synthesize friendDataGetter;
@synthesize friendUsers;
@synthesize venmoClient;
@synthesize venmoTransaction;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Friends";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    friendDataGetter = [[FriendDataGetter alloc] init];
    [friendDataGetter getFriendData:self];
}

- (void)viewDidUnload
{
    self.friendDataGetter = nil;
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(friendUsers.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(friendUsers.count > 0) {
        return friendUsers.count; //actually return the number of rows...
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the user object associated with the cell
    User *userAtPath = [friendUsers objectAtIndex:[indexPath row]];
    
    // Time to customize dat cell!
    NSString *theUsername = [NSString stringWithFormat:@"%@ %@", 
                             userAtPath.firstName, 
                             userAtPath.lastName != NULL ? userAtPath.lastName : @""];
    if(userAtPath.venmoName) {
        theUsername = [NSString stringWithFormat:@"%@ [on Venmo]", theUsername];
    }
    
    NSString *theLocation = (userAtPath.venueName!=nil ? 
                     [NSString stringWithFormat:@"@ %@", userAtPath.venueName] : @"");
    NSString *theStatus = (userAtPath.status!=nil ? 
                     [NSString stringWithFormat:@"%@", userAtPath.status] : @""); 
    
    // Set the contents of the cell
    cell.friendImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:userAtPath.photoURL]]];
    cell.usernameLabel.text = theUsername;
    cell.locationLabel.text = theLocation;
    cell.statusLabel.text = theStatus;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *friend = [friendUsers objectAtIndex:[indexPath row]];
    
    NSLog(@"FRIEND: %@", friend.foursquareID);
    NSLog(@"venmo name from 4sq id: %@", friend.venmoName);
    
    venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.amount = 5.0f;
    venmoTransaction.note = @"for a drink on me!";
    venmoTransaction.toUserHandle = friend.venmoName;

//    [HelperFunctions openWebAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    [HelperFunctions openVenmoAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - FriendDataGetterDelegate

// Get the intial list of all the users
- (void)didFinishFriendLoading:(NSString *)jsonData {
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonData error:&error];
    
    friendUsers = [[NSMutableArray alloc] init];
    NSArray *friendUsersJSON = [[[jsonObjects valueForKey:@"response"] 
                                 valueForKey:@"friends"] 
                                valueForKey:@"items"];
    
    NSEnumerator *e = [friendUsersJSON objectEnumerator];
    id userObj;
    while (userObj = [e nextObject]) {
        User *foursquareFriend = [[User alloc] init];
        foursquareFriend.userDetailDelegate = self;
        foursquareFriend.foursquareID = [userObj valueForKey:@"id"];
        foursquareFriend.firstName = [userObj valueForKey:@"firstName"];
        foursquareFriend.lastName = [userObj valueForKey:@"lastName"];
        foursquareFriend.photoURL = [userObj valueForKey:@"photo"];
        [foursquareFriend getUserDetailData:self];
        [friendUsers addObject:foursquareFriend];
    }
//    [self.tableView reloadData];
}

#pragma mark - UserDetailDelegate

- (void)didFinishUserDetailLoading {
    [self.tableView reloadData];
}

@end
