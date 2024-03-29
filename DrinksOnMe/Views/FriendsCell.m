#import "FriendsCell.h"

@implementation FriendsCell

@synthesize friendImage;
@synthesize usernameLabel;
@synthesize locationLabel;
@synthesize statusLabel;
@synthesize actionButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0.0f, 0.0f, 320.0f, 100.0f);
        
        // Time to customize dat cell!
        friendImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 50.0f, 50.0f)];
        [self addSubview:friendImage];

        usernameLabel = [[UILabel alloc] init];
        usernameLabel.frame = CGRectMake(63.0f, 5.0f, 210.0f, 21.0f);
        [usernameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        usernameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:usernameLabel];
        
        locationLabel = [[UILabel alloc] init];
        locationLabel.frame = CGRectMake(63.0f, 21.0f, 210.0f, 21.0f);
        locationLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
        locationLabel.backgroundColor = [UIColor clearColor];
        [locationLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        statusLabel = [[UILabel alloc] init];
        statusLabel.frame = CGRectMake(63.0f, 36.0f, 210.0f, 21.0f);
        statusLabel.backgroundColor = self.backgroundColor;
        [statusLabel setFont:[UIFont italicSystemFontOfSize:13.0f]];
        [self addSubview:statusLabel];
        [self addSubview:locationLabel];
        
        [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
