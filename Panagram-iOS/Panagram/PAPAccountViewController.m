//
//  PAPAccountViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPAccountViewController.h"
#import "PAPPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPLoadMoreCell.h"
#import "UIImage+ImageEffects.h"

@interface PAPAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;

    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 10.0f;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];
    
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = 10.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 0.0f;
    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 34.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 0.0f;
    [profilePictureStrokeImageView setImage:[UIImage imageNamed:@"ProfilePictureStroke.png"]];
    [self.headerView addSubview:profilePictureStrokeImageView];

    
    PFFile *imageFile = [self.user objectForKey:kPAPUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.2f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
                
                UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[image applyLightEffect]];
                backgroundImageView.frame = self.tableView.backgroundView.bounds;
                backgroundImageView.alpha = 0.0f;
                [self.tableView.backgroundView addSubview:backgroundImageView];
                
                [UIView animateWithDuration:0.2f animations:^{
                    backgroundImageView.alpha = 1.0f;
                }];
            }
        }];
    }
    
    UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
    [photoCountIconImageView setImage:[UIImage imageNamed:@"IconPics.png"]];
    [photoCountIconImageView setFrame:CGRectMake( 26.0f, 50.0f, 45.0f, 37.0f)];
    [self.headerView addSubview:photoCountIconImageView];
    
    UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 94.0f, 92.0f, 22.0f)];
    [photoCountLabel setTextAlignment:NSTextAlignmentCenter];
    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [photoCountLabel setTextColor:[UIColor whiteColor]];
    [photoCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [photoCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [photoCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [self.headerView addSubview:photoCountLabel];
    
    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
    [followersIconImageView setImage:[UIImage imageNamed:@"IconFollowers.png"]];
    [followersIconImageView setFrame:CGRectMake( 247.0f, 50.0f, 52.0f, 37.0f)];
    [self.headerView addSubview:followersIconImageView];
    
    UILabel *followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 94.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followerCountLabel setBackgroundColor:[UIColor clearColor]];
    [followerCountLabel setTextColor:[UIColor whiteColor]];
    [followerCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followerCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followerCountLabel];
    
    UILabel *followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 110.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountLabel setBackgroundColor:[UIColor clearColor]];
    [followingCountLabel setTextColor:[UIColor whiteColor]];
    [followingCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [followingCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followingCountLabel];
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor whiteColor]];
    [userDisplayNameLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    [photoCountLabel setText:@"0 photos"];
    
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
    [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [photoCountLabel setText:[NSString stringWithFormat:@"%d photo%@", number, number==1?@"":@"s"]];
            [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
        }
    }];
    
    [followerCountLabel setText:@"0 followers"];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountLabel setText:[NSString stringWithFormat:@"%d follower%@", number, number==1?@"":@"s"]];
        }
    }];

    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    [followingCountLabel setText:@"0 following"];
    if (followingDictionary) {
        [followingCountLabel setText:[NSString stringWithFormat:@"%lu following", (unsigned long)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingCountLabel setText:[NSString stringWithFormat:@"%d following", number]];
        }
    }];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureUnfollowButton];

    [PAPUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureFollowButton];

    [PAPUtility unfollowUserEventually:self.user];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
}

@end