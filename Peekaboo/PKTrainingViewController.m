//
//  PKTrainingViewController.m
//  Peekaboo
//
//  Created by Rabia Aslam on 12-02-29.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKTrainingViewController.h"
#import "CPAnimationSequence.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "PKMasterViewController.h"



static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface PKTrainingViewController () <UIGestureRecognizerDelegate>
@end

@interface PKTrainingViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface PKTrainingViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end


@implementation PKTrainingViewController
@synthesize captureManager;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize data;
@synthesize headPoseStraight;
@synthesize headPoseUp;
@synthesize headPoseDown;
@synthesize headPoseRight;
@synthesize headPoseLeft;
@synthesize headPoseSmile;
@synthesize headPoseBackground;
@synthesize messageLabel;
@synthesize counterLabel;
@synthesize testTrainingButton;
@synthesize startTrainingButton;
@synthesize aTimer;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"userTrainedMasterSegue"]) {
        PKMasterViewController *masterVC = [segue destinationViewController];
    }
}

- (void) setThatUserTrained
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserTrained"]; 
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"userTrainedMasterSegue" sender:self];
    
}


- (void)runScheduledTask {
    
    counter--;
    NSLog(@"Capture Image %d!", counter);
    //[[self captureManager] captureStillImage];
    counterLabel.text = [NSString stringWithFormat: @"%d", counter];
    
    if (counter == 1) {
        counter = 4;
        [self.aTimer invalidate];
    }
}

- (IBAction)startTraining:(id)sender 
{
    if (state!=5) 
        aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runScheduledTask) userInfo:nil repeats:YES];
    
    counterLabel.text = @""; 
    
    switch(state)
    {
        case 0:
        {
            
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0; 
                messageLabel.text = @"Look straight";
                counterLabel.alpha = 1.0;}],
                                                      [CPAnimationStep after:3 for:0 animate:^{ }],
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 1.0; 
                messageLabel.text = @"Tilt head up and TAP";
                counterLabel.alpha = 0.0;
                headPoseStraight.alpha = 0.0;
                headPoseUp.alpha = 1.0; }],
                                                      nil];
            [animationSequence run];
            state = 1;
            
            break;
        }
        case 1:
        {
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0;
                messageLabel.text = @"Tilt head up";
                counterLabel.alpha = 1.0;}],
                                                      [CPAnimationStep after:3 for:0 animate:^{ }],
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 1.0; 
                messageLabel.text = @"Tilt head down and TAP";
                counterLabel.alpha = 0.0;
                headPoseUp.alpha = 0.0;
                headPoseDown.alpha = 1.0; }],
                                                      nil];
            [animationSequence run];
            state = 2;
            
            break;
        }
        case 2:
        {
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0;
                messageLabel.text = @"Tilt head down";
                counterLabel.alpha = 1.0;}],
                                                      [CPAnimationStep after:3 for:0 animate:^{ }],
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 1.0; 
                messageLabel.text = @"Tilt head right and TAP";
                counterLabel.alpha = 0.0;
                headPoseDown.alpha = 0.0;
                headPoseRight.alpha = 1.0;}],
                                                      nil];
            [animationSequence run];
            state = 3;
            
            break;
        }
        case 3:
        {
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0;
                messageLabel.text = @"Tilt head right";
                counterLabel.alpha = 1.0;}],
                                                      [CPAnimationStep after:3 for:0 animate:^{ }],
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 1.0; 
                messageLabel.text = @"Tilt head left and TAP";
                counterLabel.alpha = 0.0;
                headPoseRight.alpha = 0.0;
                headPoseLeft.alpha = 1.0;}],
                                                      nil];
            [animationSequence run];
            state = 4;
            
            break;
        }
        case 4:
        {
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0;
                messageLabel.text = @"Tilt head left";
                counterLabel.alpha = 1.0;}],
                                                      [CPAnimationStep after:3 for:0 animate:^{ }],
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 1.0; 
                messageLabel.text = @"Training Completed! TAP to close.";
                counterLabel.alpha = 0.0;
                headPoseLeft.alpha = 0.0;
                headPoseSmile.alpha = 1.0;}],
                                                      nil];
            [animationSequence run];
            state = 5;
            
            break;
        }
        case 5:
        {
            CPAnimationSequence* animationSequence = [CPAnimationSequence sequenceWithSteps:
                                                      [CPAnimationStep after:0 for:0.5 animate:^{ self.startTrainingButton.alpha = 0.0;
                self.messageLabel.alpha = 0.0;
                self.counterLabel.alpha = 0.0;
                self.headPoseSmile.alpha = 0.0;
                headPoseBackground.alpha = 0.0;}],
                                                      nil];
            [animationSequence run];
            state = 0;
            
            aTimer = nil; 
            
            [self setThatUserTrained]; 
            
            break;
        }
        default:
            break;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    state = 0;
    counter = 4;
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    
    
    if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
				[newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
						
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
            
            // Toggle between cameras when there is more than one
            [[self captureManager] toggleCamera];
        }
    }

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
@implementation PKTrainingViewController (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates 
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}
@end

@implementation PKTrainingViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        //[[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
        //[[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        //[[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
        //[[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    //[self setCapturedImage:[self.captureManager lastCapturedImage]];
    //[self performSegueWithIdentifier:@"testSegue" sender:nil];
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        //[[self stillButton] setEnabled:YES];
    });
    
    
}


- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
}

@end

