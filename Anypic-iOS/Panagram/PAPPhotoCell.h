//
//  PAPPhotoCell.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

@class PFImageView;
@interface PAPPhotoCell : PFTableViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

- (void) updateScrollViewWidthWithImage:(UIImage*) image;

@end
