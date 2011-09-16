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
        self.title = @"Venue!";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainUser = [[User alloc] init];
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
    
    NSLog(@"count: %d", checkedInUsers.count);
    NSLog(@"index path row: %d", [indexPath row]);
    NSLog(@"index path section: %d", [indexPath section]);
    User *userAtPath = [checkedInUsers objectAtIndex:[indexPath row]];

    cell.friendImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:userAtPath.photoURL]]];
    cell.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", 
                               userAtPath.firstName, 
                               userAtPath.lastName != NULL ? userAtPath.lastName : @""];
    
    // Time to customize dat cell!
    [cell.friendImage setBackgroundColor:[UIColor greenColor]];
    [cell.locationLabel setText:@"@ Batcave 3:14 am"];
    [cell.statusLabel setText:@"No tolerance for baddies."];
//    [cell.locationLabel setText:@""];
//    [cell.statusLabel setText:@""];
//    [cell.actionButton setTitle:@"Bam" forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
        [checkedInUsers addObject:checkedInUser];
        NSLog(@"added a user");
    }
    [self.tableView reloadData];
}

@end
