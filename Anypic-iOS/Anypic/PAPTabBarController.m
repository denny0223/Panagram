//
//  PAPTabBarController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPTabBarController.h"

@interface PAPTabBarController ()
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation PAPTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
//    [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"BackgroundTabBarItemSelected.png"]];
    self.tabBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:111.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
    
    /*
     // iOS 7 style
     self.tabBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:111.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
     self.tabBar.barTintColor = [UIColor colorWithRed:77.0f/255.0f green:49.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
     */
    self.navController = [[UINavigationController alloc] init];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:self.navController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 94.0f, 0.0f, 131.0f, self.tabBar.bounds.size.height);
    [cameraButton setImage:[UIImage imageNamed:@"ButtonCamera.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"ButtonCameraSelected.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:cameraButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
     
    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController pushViewController:viewController animated:NO];
    
    [self presentViewController:self.navController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showFromTabBar:self.tabBar];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
//    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;

    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO 
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
//    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}

@end
