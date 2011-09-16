#import "VenueViewController.h"
#import "../Views/FriendsCell.h"

@implementation VenueViewController

@synthesize venmoClient;
@synthesize venmoTransaction;
@synthesize mainUser;
@synthesize venueCheckinsDataGetter;
@synthesize checkedInUsers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [mainUser getUserData:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (checkedInUsers.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (checkedInUsers.count > 0) {
        return checkedInUsers.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Same implementation from FriendsViewController, but with a different cell identifier
    static NSString *CellIdentifier = @"VenueCell";
    
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the user object associated with the cell
    User *userAtPath = [checkedInUsers objectAtIndex:[indexPath row]];
    
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
    // same implementation from FriendsViewController
    User *friend = [checkedInUsers objectAtIndex:[indexPath row]];
    
    NSLog(@"FRIEND: %@", friend.foursquareID);
    NSLog(@"Venmo name from 4sq id: %@", friend.venmoName);
    
    // set the features on the transaction object
    venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.amount = 5.0f;
    venmoTransaction.note = @"for a drink on me!";
    venmoTransaction.toUserHandle = friend.venmoName;
    
    // this will show a venmo WEB VIEW payment scheme:
    //[HelperFunctions openWebAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    
    // this will show a venmo APP VIEW payment scheme (if Venmo is installed and at current version):
    [HelperFunctions openVenmoAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    
    // deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UserDelegate

/**
 * This gets the main user's 4sq id and venue that he's checked in at.
 */
- (void)didFinishUserLoading:(NSString *)jsonData {
    // the main thing is to get the id of the venue
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonData error:&error];
    NSArray *userJSON = [[jsonObjects valueForKey:@"response"] valueForKey:@"user"];
    NSObject *venue = [[[[userJSON valueForKey:@"checkins"] valueForKey:@"items"] 
                        objectAtIndex:0] valueForKey:@"venue"];
    
    mainUser.foursquareID = [userJSON valueForKey:@"id"];
    mainUser.venueID = [venue valueForKey:@"id"];
    mainUser.venueName = [venue valueForKey:@"name"];
    
    NSLog(@"foursquare user data retrieved %@", mainUser.venueID);
    
    // now with the venue id, get all the people that are checked in there
    venueCheckinsDataGetter = [[VenueCheckinsDataGetter alloc] init];
    [venueCheckinsDataGetter getVenueData:self venueId:mainUser.venueID];
}

#pragma mark - VenueCheckinsDataGetterDelegate

/**
 * The 4sq users that are checked in at a current venue have been loaded.
 */
- (void)didFinishVenueCheckinLoading:(NSString *)jsonData {
    // the users that are checked in have been received
    checkedInUsers = [[NSMutableArray alloc] init];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonData error:&error];
    NSArray *venueJSON = [[[jsonObjects valueForKey:@"response"] valueForKey:@"hereNow"] valueForKey:@"items"];
    
    NSEnumerator *e = [venueJSON objectEnumerator];
    id checkedInObj;
    while (checkedInObj = [e nextObject]) {
        NSArray *checkedInArray = [checkedInObj valueForKey:@"user"];
        User *checkedInUser = [[User alloc] init];
        checkedInUser.foursquareID = [checkedInArray valueForKey:@"id"];
        checkedInUser.firstName = [checkedInArray valueForKey:@"firstName"];
        checkedInUser.lastName = [checkedInArray valueForKey:@"lastName"];
        checkedInUser.photoURL = [checkedInArray valueForKey:@"photo"];
        
        // send yet another http request to check if the 4sq user has venmo and connected 4sq to it
        //  (if they're connected with venmo, you can buy them a drink them)
        [checkedInUser getUserDetailData:self];
        [checkedInUsers addObject:checkedInUser];
    }
    [self.tableView reloadData];
}

#pragma mark - UserDetailDelegate

/**
 * Now the app has verified which 4sq users have venmo and are connected to 4sq. Reload the table.
 */
- (void)didFinishUserDetailLoading {
    [self.tableView reloadData];
}

@end
