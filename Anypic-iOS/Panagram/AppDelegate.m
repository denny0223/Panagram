//
//  AppDelegate.m
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"

@interface AppDelegate () {
    BOOL firstLaunch;
}

@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // ****************************************************************************
    // Parse initialization
    // [Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY"];
    [Parse setApplicationId:@"cLXA3EhzyvWXitzfo8VNlqFEetDG9vKQgt87P85F" clientKey:@"O5EtsbdS59icxwKXqYm3WfLyYKUjHVX4pj5UOazj"];
    [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Set up our app's global UIAppearance
    [self setupAppearance];

    // Use Reachability to monitor connectivity
    [self monitorReachability];

    self.welcomeViewController = [[PAPWelcomeViewController alloc] init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;

    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    [self handlePush:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}


#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        self.hud.labelText = NSLocalizedString(@"Loading", nil);
        self.hud.dimBackground = YES;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [self facebookRequestDidLoad:result];
        } else {
            [self facebookRequestDidFailWithError:error];
        }
    }];
}



#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self.welcomeViewController presentViewController:loginViewController animated:NO completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {    
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"Home") image:[[UIImage imageNamed:@"IconHome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconHomeSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", @"Activity") image:[[UIImage imageNamed:@"IconTimeline.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconTimelineSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, emptyNavigationController, activityFeedNavigationController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
        
}

- (void)logOut {
    // clear cache
    [[PAPCache sharedCache] clear];

    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
}


#pragma mark - ()

// Set up appearance parameters to achieve Anypic's custom look and feel
- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.750f];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);

    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSShadowAttributeName: shadow
                                }];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"]
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f]
     forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                NSForegroundColorAttributeName:
                                    [UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f],
                                NSShadowAttributeName: shadow
                                }
                                                forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];

    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {

    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
                
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];

        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }

    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:kPAPUserFacebookFriendsKey]) {
                [user removeObjectForKey:kPAPUserFacebookFriendsKey];
            }
            
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Anypic
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *parseEmployeesQuery = [PFUser query];
                [parseEmployeesQuery whereKey:kPAPUserFacebookIDKey containedIn:kPAPParseEmployeeAccounts];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:parseEmployeesQuery,facebookFriendsQuery, nil]];
                
                NSArray *anypicFriends = [query findObjects:&error];
                
                if (!error) {
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);

        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

@end
