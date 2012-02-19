//
//  PKDetailViewController.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKDetailViewController.h"
#import "SVProgressHUD.h"
#import "PersonViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"


@implementation PKDetailViewController

@synthesize capturedImageView;
@synthesize capturedImage;
@synthesize retrievedFacesObject;
@synthesize facesLabel;
@synthesize facesSubTextLabel;
@synthesize tempRecognizeButton;
@synthesize lastParseId;
@synthesize retrievedFacebookId;


#pragma mark - Managing the imageview




- (void)configureView
{
    // Update the user interface for the detail item.
    
    self.capturedImageView.image = self.capturedImage;
    [self.capturedImageView.layer setCornerRadius:5.0f];
    
    [facesLabel.layer setCornerRadius:5.0f];
    [facesSubTextLabel.layer setCornerRadius:5.0f];
    
    facesLabel.layer.borderWidth = 1.0f;
    facesSubTextLabel.layer.borderWidth = 1.0f;

    facesLabel.layer.borderColor = [UIColor blackColor].CGColor;
    facesSubTextLabel.layer.borderColor = [UIColor blackColor].CGColor;

//    self.capturedImageView.layer.borderWidth = 1.0;
//    [self.capturedImageView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    
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
        CGFloat y = ([[(NSDictionary *)[tag objectForKey:@"center"] objectForKey:@"y"] floatValue] * capturedImageView.frame.size.height) / 110; //was /100 before, this is a hack to get images to be vertically aligned properly on someones face.
        
        //CGFloat roll = [[tag objectForKey:@"roll"] floatValue];
        
        //UIButton *square = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];

        UIButton *square = [UIButton buttonWithType:UIButtonTypeCustom];
        square.frame = CGRectMake(0, 0, width, height);
        square.backgroundColor = [UIColor clearColor];
        square.layer.borderWidth = 3.0;
        [square.layer setCornerRadius:5.0f];
        [square.layer setBorderColor:[UIColor whiteColor].CGColor];
        square.layer.shadowColor = [UIColor cyanColor].CGColor;
        square.layer.shadowRadius = 3;
        square.layer.shadowOpacity = .7;
        square.layer.shadowOffset = CGSizeMake(0, 1);
        square.center = CGPointMake(x, y);
        
        
        //[square setTransform:CGAffineTransformMakeRotation([self DegreesToRadians:roll])];
        
        //This shit here is important - it makes the square clickable. I had to spend a good 1hr figuring this out. 
        square.userInteractionEnabled = YES;
        [square addTarget:self action:@selector(faceTouchUpInside:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
        
        //make sure the square is added as a child to the VIEW instead of the imageView. Otherwise, the imageview will capture all the touch events
        [self.view addSubview:square];
        [self.view bringSubviewToFront:square];
        
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

- (void)faceTouchUpInside:(id)sender {
    NSLog(@"Touch Up Inside Performed");
    [SVProgressHUD showWithStatus:@"Recognizing..." maskType:SVProgressHUDMaskTypeBlack networkIndicator:YES];
    [self checkIfRecognized];
    //[self performSegueWithIdentifier:@"showPersonViewSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
     When a row is selected, the segue creates the detail view controller as the destination.
     Set the detail view controller's detail item to the item associated with the selected row.
     */
    if ([[segue identifier] isEqualToString:@"showPersonViewSegue"]) {
        
        PersonViewController *personVC  = segue.destinationViewController;
        [personVC setFacebookId:self.retrievedFacebookId];
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



#pragma mark - Face Recognition Methods

- (void) checkIfRecognized {
    
    NSString *urlString = [NSString stringWithFormat:@"http://stormy-moon-8803.herokuapp.com/api/getResultForRecognizedImageWithId/%@", self.lastParseId];
    
    
    //NSString *urlString = [NSString stringWithFormat:@"http://stormy-moon-8803.herokuapp.com/api/getResultForRecognizedImageWithId/%@", @"j4deV7okxD"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //If we get empty JSON back, then the recognition process has not completed. Query Again.
    NSString *responseString = [request responseString];
    
    if ([responseString isEqualToString:@"{}"]) {
        [self checkIfRecognized];
    }
    
    //If something has been retrieved, send it here.
    else {
        
        [SVProgressHUD dismissWithSuccess:@"Recognition Complete"];
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        // parse the JSON string into an object - assuming json_string is a NSString of JSON data
        NSDictionary *responseObj = [parser objectWithString:responseString error:nil];
        [self setRetrievedFacebookId:[responseObj objectForKey:@"facebookId"]];      
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Test"
                              message: self.retrievedFacebookId
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        
        [self performSegueWithIdentifier:@"showPersonViewSegue" sender:nil];
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: @"There was an error during the recognition process. Try again?"
                          delegate: nil
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil];
    [alert show];
    
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
