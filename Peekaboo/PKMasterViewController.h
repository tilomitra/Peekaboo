//
//  PKMasterViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer, PKDetailViewController;


@interface PKMasterViewController : UIViewController <UIImagePickerControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PKDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


//AVCAM
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic,retain) IBOutlet UIButton *recordButton;
@property (nonatomic,retain) IBOutlet UIButton *stillButton;
@property (nonatomic,retain) IBOutlet UILabel *focusModeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *instructionImageView;
@property (nonatomic, retain) UIImage *capturedImage;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSDictionary *retrievedFacesObject;
@property (nonatomic, retain) NSString *retrievedParseId;

//ZUIViewController Pan Gesture Recognizer
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;

- (IBAction)toggleRecording:(id)sender;
- (IBAction)captureStillImage:(id)sender;
- (IBAction)toggleCamera:(id)sender;

- (IBAction)loadFacebookPersonView:(id)sender;

- (void)navigateToDetailViewWithImage:(UIImage *)image;

- (void)hideInstructionImageView:(UITapGestureRecognizer *)tapGestureRecognizer;
@end
