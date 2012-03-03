//
//  PKTrainingViewController.h
//  Peekaboo
//
//  Created by Rabia Aslam on 12-02-29.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;
@interface PKTrainingViewController : UIViewController <UIImagePickerControllerDelegate, NSFetchedResultsControllerDelegate> {
     NSTimer *aTimer;
    int state;
    int counter;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//AVCAM
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, retain) NSArray *data;

@property (nonatomic,retain) IBOutlet UIView *headPoseStraight;
@property (nonatomic,retain) IBOutlet UIView *headPoseUp;
@property (nonatomic,retain) IBOutlet UIView *headPoseDown;
@property (nonatomic,retain) IBOutlet UIView *headPoseRight;
@property (nonatomic,retain) IBOutlet UIView *headPoseLeft;
@property (nonatomic,retain) IBOutlet UIView *headPoseSmile;
@property (nonatomic,retain) IBOutlet UIView *headPoseBackground;
@property (nonatomic,retain) IBOutlet UILabel *messageLabel;
@property (nonatomic,retain) IBOutlet UILabel *counterLabel;
@property (nonatomic,retain) IBOutlet UIButton *testTrainingButton;
@property (nonatomic,retain) IBOutlet UIButton *startTrainingButton;
@property (nonatomic, retain) NSTimer *aTimer;

- (IBAction)startTraining:(id)sender;
- (void)runScheduledTask; 

@end
