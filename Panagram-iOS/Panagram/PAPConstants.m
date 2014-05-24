//
//  PAPConstants.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPConstants.h"

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"com.parse.Anypic.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.parse.Anypic.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Anypic.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"com.parse.Anypic.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedPhoto";
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.parse.Anypic.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPAPInstallationUserKey = @"user";

#pragma mark - Activity Class
// Class key
NSString *const kPAPActivityClassKey = @"Activity";

// Field keys
NSString *const kPAPActivityTypeKey        = @"type";
NSString *const kPAPActivityFromUserKey    = @"fromUser";
NSString *const kPAPActivityToUserKey      = @"toUser";
NSString *const kPAPActivityContentKey     = @"content";
NSString *const kPAPActivityPhotoKey       = @"photo";

// Type values
NSString *const kPAPActivityTypeLike       = @"like";
NSString *const kPAPActivityTypeFollow     = @"follow";
NSString *const kPAPActivityTypeComment    = @"comment";
NSString *const kPAPActivityTypeJoined     = @"joined";

#pragma mark - User Class
// Field keys
NSString *const kPAPUserDisplayNameKey                          = @"displayName";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserPhotoIDKey                              = @"photoId";
NSString *const kPAPUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPAPUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPAPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";

#pragma mark - Photo Class
// Class key
NSString *const kPAPPhotoClassKey = @"Photo";

// Field keys
NSString *const kPAPPhotoPictureKey         = @"image";
NSString *const kPAPPhotoThumbnailKey       = @"thumbnail";
NSString *const kPAPPhotoUserKey            = @"user";
NSString *const kPAPPhotoOpenGraphIDKey    = @"fbOpenGraphID";


#pragma mark - Cached Photo Attributes
// keys
NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kPAPPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kPAPPhotoAttributesLikersKey               = @"likers";
NSString *const kPAPPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPAPPushPayloadPayloadTypeKey          = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadPhotoObjectIdKey    = @"pid";