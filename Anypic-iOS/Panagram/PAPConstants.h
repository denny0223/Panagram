//
//  PAPConstants.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
	PAPHomeTabBarItemIndex = 0,
	PAPEmptyTabBarItemIndex = 1,
	PAPActivityTabBarItemIndex = 2
} PAPTabBarControllerViewControllerIndex;


// Ilya     400680
// James    403902
// Brian    702499
// David    1225726
// Bryan    4806789
// Thomas   6409809
// Ashley   12800553
// Héctor   121800083
// Kevin    500011038
// Chris    558159381
// Henele   721873341
// Matt     723748661
// Andrew   865225242

#define kPAPParseEmployeeAccounts [NSArray arrayWithObjects:@"400680", @"403902", @"702499", @"1225726", @"4806789", @"6409809", @"12800553", @"121800083", @"500011038", @"558159381", @"721873341", @"723748661", @"865225242", nil]

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PAPUtilityUserFollowingChangedNotification;
extern NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - User Info Keys
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPAPActivityClassKey;

// Field keys
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityPhotoKey;

// Type values
extern NSString *const kPAPActivityTypeLike;
extern NSString *const kPAPActivityTypeFollow;
extern NSString *const kPAPActivityTypeComment;
extern NSString *const kPAPActivityTypeJoined;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPUserPhotoIDKey;
extern NSString *const kPAPUserProfilePicSmallKey;
extern NSString *const kPAPUserProfilePicMediumKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kPAPPhotoClassKey;

// Field keys
extern NSString *const kPAPPhotoPictureKey;
extern NSString *const kPAPPhotoThumbnailKey;
extern NSString *const kPAPPhotoUserKey;
extern NSString *const kPAPPhotoOpenGraphIDKey;


#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPPhotoAttributesLikeCountKey;
extern NSString *const kPAPPhotoAttributesLikersKey;
extern NSString *const kPAPPhotoAttributesCommentCountKey;
extern NSString *const kPAPPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypeKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadPhotoObjectIdKey;