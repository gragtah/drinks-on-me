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
                                                     [NSURL URLWithString:userAtPath.photoURLString]]];
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
    NSLog(@"Venmo name from 4sq id: %@", friend.venmoName);
    
    // set the features on the transaction object
    venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.amount = 5.0f;
    venmoTransaction.note = @"for a drink on me!";
    venmoTransaction.toUserHandle = friend.venmoName;

    // this will show a venmo WEB VIEW payment scheme:
//    [HelperFunctions openWebAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    
    // this will show a venmo APP VIEW payment scheme (if Venmo is installed and at current version):
    [HelperFunctions openVenmoAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    
    // deselect the row
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
    
    //Initial call to 4sq api gets a JSON list of all the user's friends. Parse the JSON
    // and add them to the datasource array of the table view
    NSEnumerator *e = [friendUsersJSON objectEnumerator];
    id userObj;
    while (userObj = [e nextObject]) {
        User *foursquareFriend = [[User alloc] init];
        foursquareFriend.userDetailDelegate = self;
        foursquareFriend.foursquareID = [userObj valueForKey:@"id"];
        foursquareFriend.firstName = [userObj valueForKey:@"firstName"];
        foursquareFriend.lastName = [userObj valueForKey:@"lastName"];
        foursquareFriend.photoURLString = [userObj valueForKey:@"photo"];
        
        // look up the 4sq friend's public information: like email, phone, twitter, fbook
        [foursquareFriend getUserDetailData:self];
        
        // add the 4sq friend to the datasource
        [friendUsers addObject:foursquareFriend];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UserDetailDelegate

// when the 4sq friends' data is received from the server, reload the table view with new data
- (void)didFinishUserDetailLoading {
    [self.tableView reloadData];
}

@end
