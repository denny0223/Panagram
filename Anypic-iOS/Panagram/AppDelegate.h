//
//  AppDelegate.h
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) PAPTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
- (void)presentTabBarController;

- (void)logOut;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;

@end
