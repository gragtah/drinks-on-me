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
    if (self) {
//        self.title = @"Venue!";
    }
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    static NSString *CellIdentifier = @"VenueCell";
    
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    User *userAtPath = [checkedInUsers objectAtIndex:[indexPath row]];
    
    // Time to customize dat cell!
    cell.friendImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:userAtPath.photoURL]]];
    cell.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", 
                               userAtPath.firstName, 
                               userAtPath.lastName != NULL ? userAtPath.lastName : @""];
    
    NSString *theLocation = (userAtPath.venueName!=nil ? 
                             [NSString stringWithFormat:@"@ %@", userAtPath.venueName] : @"");
    NSString *theStatus = (userAtPath.status!=nil ? 
                           [NSString stringWithFormat:@"@ %@", userAtPath.status] : @""); 
    [cell.locationLabel setText:theLocation];
    [cell.statusLabel setText:theStatus];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *friend = [checkedInUsers objectAtIndex:[indexPath row]];
    
    NSLog(@"FRIEND: %@", friend.foursquareID);
    NSLog(@"venmo name from 4sq id: %@", friend.venmoName);
    
    venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.amount = 0.01f;
    venmoTransaction.note = @"for a drink on me!";
    venmoTransaction.toUserHandle = friend.venmoName;
    
    //    [HelperFunctions openWebAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    [HelperFunctions openVenmoAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UserDelegate

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
    
    // with the venue id, get all the people that are checked in there
    venueCheckinsDataGetter = [[VenueCheckinsDataGetter alloc] init];
    [venueCheckinsDataGetter getVenueData:self venueId:mainUser.venueID];
}

#pragma mark - VenueCheckinsDataGetterDelegate

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
        [checkedInUser getUserDetailData:self];
        [checkedInUsers addObject:checkedInUser];
    }
    [self.tableView reloadData];
}

#pragma mark - UserDetailDelegate

- (void)didFinishUserDetailLoading {
    [self.tableView reloadData];
}

@end
