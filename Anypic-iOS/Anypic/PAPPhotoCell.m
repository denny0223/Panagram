//
//  PAPPhotoCell.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoCell.h"
#import "PAPUtility.h"

@implementation PAPPhotoCell
@synthesize scrollView;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];

        UIView *dropshadowView = [[UIView alloc] init];
        dropshadowView.backgroundColor = [UIColor whiteColor];
        dropshadowView.frame = CGRectMake( 20.0f, -44.0f, 280.0f, 322.0f);
        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
        
        self.imageView.backgroundColor = [UIColor blackColor];
        [self.imageView setFrame:CGRectMake(0.0f,0.0f,280.f,280.f)];
        [self.imageView removeFromSuperview];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f)];
        [self.scrollView setBounces:false];


        [self.scrollView addSubview:self.imageView];
        
        [self.contentView addSubview:self.scrollView];
        
        [self.contentView bringSubviewToFront:self.scrollView];
    }

    return self;
}



#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateScrollViewWidthWithImage:self.imageView.image];
}


#pragma mark - PAPPhotoCell

- (void) updateScrollViewWidthWithImage:(UIImage *)image
{
    [PAPUtility updateScrollView:self.scrollView andImageView:self.imageView withImage:image];
}

@end
