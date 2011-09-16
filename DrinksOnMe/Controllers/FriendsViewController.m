#import "FriendsViewController.h"
#import "../Views/FriendsCell.h"

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
    
    User *userAtPath = [friendUsers objectAtIndex:[indexPath row]];
    
    // Time to customize dat cell!
    cell.friendImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:userAtPath.photoURL]]];
    cell.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", 
                                 userAtPath.firstName, 
                                 userAtPath.lastName != NULL ? userAtPath.lastName : @""];
    [cell.locationLabel setText:@"@ Charlies 10:08 pm"];
    [cell.statusLabel setText:@"The apple martini looks delicious!"];
//    [cell.locationLabel setText:@""];
//    [cell.statusLabel setText:@""];
//    [cell.actionButton setTitle:@"Bam" forState:UIControlStateNormal];
//    [cell.actionButton addTarget:self action:@selector(showVenmoPayment) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)showVenmoPayment {
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *friend = [friendUsers objectAtIndex:[indexPath row]];
    
    venmoTransaction = [[VenmoTransaction alloc] init];
    venmoTransaction.amount = 0.01f;
    venmoTransaction.note = @"for a drink on me!";
    venmoTransaction.toUserId = friend.foursquareID;

//    [HelperFunctions openWebAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
    [HelperFunctions openVenmoAction:self venmoClient:venmoClient venmoTransaction:venmoTransaction];
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
        foursquareFriend.foursquareID = [userObj valueForKey:@"id"];
        foursquareFriend.firstName = [userObj valueForKey:@"firstName"];
        foursquareFriend.lastName = [userObj valueForKey:@"lastName"];
        foursquareFriend.photoURL = [userObj valueForKey:@"photo"];
        [friendUsers addObject:foursquareFriend];
    }
    [self.tableView reloadData];
}

- (void)didFinishUserDetailLoading:(NSString *)jsonData {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonData error:&error];
    
    NSString *receivedFoursquareId = [[[jsonObjects 
                                        valueForKey:@"response"] 
                                       valueForKey:@"user"] 
                                      valueForKey:@"id"];
    
//    User *matchedUser;
//    for(User foursquareFriend in friendUsers) {
//        if () {
//            <#statements#>
//        }
//    }
}

@end

/*
 response: {
    user: {
    id: "3789071"
    firstName: "Matt"
    lastName: "Di Pasquale"
    photo: "https://playfoursquare.s3.amazonaws.com/userpix_thumbs/V5CPVTZZ0PECUVPF.jpg"
    gender: "male"
    homeCity: "Westport, CT"
    relationship: "friend"
    type: "user"
    pings: true
    contact: {
        phone: "6178940859"
        email: "liveloveprosper@gmail.com"
        twitter: "mattdipasquale"
        facebook: "514417"
    }
 */
