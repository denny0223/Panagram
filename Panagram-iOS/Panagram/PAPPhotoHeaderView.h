//
//  PAPPhotoHeaderView.h
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
    PAPPhotoHeaderButtonsNone = 0,
    PAPPhotoHeaderButtonsLike = 1 << 0,
    PAPPhotoHeaderButtonsComment = 1 << 1,
    PAPPhotoHeaderButtonsUser = 1 << 2,
    
    PAPPhotoHeaderButtonsDefault = PAPPhotoHeaderButtonsLike | PAPPhotoHeaderButtonsComment | PAPPhotoHeaderButtonsUser
} PAPPhotoHeaderButtons;

@protocol PAPPhotoHeaderViewDelegate;

@interface PAPPhotoHeaderView : UIView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PAPPhotoHeaderButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Photo button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPPhotoHeaderViewDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a PAPPhotoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol PAPPhotoHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like photo button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;

/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

@end