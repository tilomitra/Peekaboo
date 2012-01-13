//
//  PKDetailViewController.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKDetailViewController.h"
#import "SVProgressHUD.h"

@interface PKDetailViewController ()
- (void)configureView;
- (void)configureFaceLabelWith:(int)numberOfFaces;
@end

@implementation PKDetailViewController

@synthesize capturedImageView;
@synthesize capturedImage;
@synthesize retrievedFacesObject;
@synthesize facesLabel;
@synthesize facesSubTextLabel;

#pragma mark - Managing the imageview


- (void)configureView
{
    // Update the user interface for the detail item.
    
    self.capturedImageView.image = self.capturedImage;
    [self.capturedImageView.layer setCornerRadius:3.0f];
    self.capturedImageView.layer.borderWidth = 1.0;
    [self.capturedImageView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Drawing Faces

- (void)drawFaces:(NSArray *)tags
{
    
    //update the labels with the appropriate text.
    [self configureFaceLabelWith:[tags count]];
    
    for (NSDictionary *tag in tags)
    {
        // You can retrieve individual values using objectForKey on the status NSDictionary
        // This will print the tweet and username to the console
        
        NSLog(@"The width is %@", [tag objectForKey:@"width"]);
        CGFloat width = ([[tag objectForKey:@"width"] floatValue] * capturedImageView.frame.size.width) / 100;
        CGFloat height = ([[tag objectForKey:@"height"] floatValue] * capturedImageView.frame.size.height) / 100;
        CGFloat x = ([[(NSDictionary *)[tag objectForKey:@"center"] objectForKey:@"x"] floatValue] * capturedImageView.frame.size.width) / 100;
        CGFloat y = ([[(NSDictionary *)[tag objectForKey:@"center"] objectForKey:@"y"] floatValue] * capturedImageView.frame.size.height) / 100;
        
        CGFloat roll = [[tag objectForKey:@"roll"] floatValue];
        
        UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        square.backgroundColor = [UIColor clearColor];
        square.layer.borderWidth = 2.0;
        [square.layer setCornerRadius:5.0f];
        [square.layer setBorderColor:[UIColor whiteColor].CGColor];
        square.layer.shadowColor = [UIColor cyanColor].CGColor;
        square.layer.shadowRadius = 2;
        square.layer.shadowOpacity = .2;
        square.layer.shadowOffset = CGSizeMake(0, 1);
        square.center = CGPointMake(x, y);
        //[square setTransform:CGAffineTransformMakeRotation([self DegreesToRadians:roll])];
        
        [capturedImageView addSubview:square];
        
        CABasicAnimation *theAnimation;
        
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=0.5;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [square.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }
    
}

- (void)configureFaceLabelWith:(int)numberOfFaces {
    
    NSString *labelText = [[NSString alloc] init];
    NSString *subLabelText = [[NSString alloc] init];
    

    if (numberOfFaces > 0 && numberOfFaces != 1) {
        labelText = [NSString stringWithFormat:@"%d Faces Detected", numberOfFaces];
        subLabelText = [NSString stringWithFormat:@"Select a person by tapping on them."];
    }
    //special case to use the singular "face" instead of "faces"
    else if (numberOfFaces == 1) {
        labelText = [NSString stringWithFormat:@"%d Face Detected", numberOfFaces];
        subLabelText = [NSString stringWithFormat:@"Select a person by tapping on them."];
    }
    
    //pretty much numberOfFaces == 0.
    else {
        labelText = [NSString stringWithFormat:@"No Faces Detected"];
        subLabelText = [NSString stringWithFormat:@"You may be too far away, or the lighting may be bad. Try again."];
    }
    
    self.facesSubTextLabel.text = subLabelText;
    self.facesLabel.text = labelText;
    
    [capturedImageView addSubview:facesLabel];
    [capturedImageView addSubview:facesSubTextLabel];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set image on imageview and add some rounded corners.
    [self configureView];
    
    NSArray *tags = (NSArray *)[self.retrievedFacesObject objectForKey:@"tags"];
    [self drawFaces:tags];
    NSLog(@"All done");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    //return NO;
}

#pragma mark Face Detection Methods
@end
