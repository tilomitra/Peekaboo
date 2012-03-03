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
#import "UIImage+ProportionalFill.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

static NSString *FACE_API_KEY = @"f28554fbd62ae04011c90b4895195481";
static NSString *FACE_API_SECRET = @"e08dc8763856d45e2e479ed4d961b1fa";

@implementation PKDetailViewController

@synthesize capturedImageView;
@synthesize capturedImage;
@synthesize retrievedFacesObject;
@synthesize facesLabel;
@synthesize facesSubTextLabel;
@synthesize lastParseId;
@synthesize retrievedFacebookId;
@synthesize detectedFacesTags;
@synthesize squaresArray;
@synthesize squareAnimation;
#pragma mark - Managing the imageview




- (void)configureView
{
    // Update the user interface for the detail item.
    self.capturedImageView.image = self.capturedImage;
    [self.capturedImageView.layer setCornerRadius:5.0f];
//    self.capturedImageView.layer.borderWidth = 1.0;
//    [self.capturedImageView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    
}

#pragma mark - Learning

//Implements learning. If tid has a uid which is in the green, the tid is sent to face.com be trained, to improve the recognition of the person in the future
- (void)learnFromTag:(NSDictionary *)tag {
    
    NSString *tagId = [tag objectForKey:@"tid"];
    NSDictionary *mostLikelyPerson = (NSDictionary *)[(NSArray *)[tag objectForKey:@"uids"] objectAtIndex:0];
    
    
    if ([self findDifferenceBetweenConfidenceAndThresholdForTag:tag] > 25) {
        NSURL *tagSaveApiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.face.com/tags/save.json?api_key=%@&api_secret=%@&uid=%@&tids=%@", FACE_API_KEY, FACE_API_SECRET, [mostLikelyPerson objectForKey:@"uid"], tagId]];
        

        
        NSLog(@"Confidence is high - starting learning protocols with URL %@", tagSaveApiUrl);
        
        __block ASIHTTPRequest *tagSaveRequest = [ASIHTTPRequest requestWithURL:tagSaveApiUrl];
        [tagSaveRequest setCompletionBlock:^{
            //NSLog(@"%@", [tagSaveRequest responseString]);
            
            //SBJsonParser *parser = [[SBJsonParser alloc] init];
            //NSDictionary *responseObj = [parser objectWithString:[tagSaveRequest responseString]];
            
            //start the face training request
            NSURL *faceTrainApiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.face.com/faces/train.json?api_key=%@&api_secret=%@&uids=%@", FACE_API_KEY, FACE_API_SECRET, [mostLikelyPerson objectForKey:@"uid"]]];
            
            NSLog(@"Starting training protocols with URL %@", faceTrainApiUrl);

            __block ASIHTTPRequest *faceTrainRequest = [ASIHTTPRequest requestWithURL:faceTrainApiUrl];
            [faceTrainRequest setCompletionBlock:^{
                NSLog(@"The user was trained successfully based on the picture passed.");
            }];
            
            [faceTrainRequest setFailedBlock:^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error when training the system with this image." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                // optional - add more buttons:
                [alert show]; 
            }];
        }];
         
        [tagSaveRequest setFailedBlock:^{
            //NSLog(@"%@",[tagSaveRequest error]); 
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error when saving the tag of this image." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert show];
        }];
        [tagSaveRequest startAsynchronous];
        
        
    }
}


#pragma mark - Drawing Faces

- (int)findDifferenceBetweenConfidenceAndThresholdForTag:(NSDictionary *)tag {
    NSArray *uidArray = (NSArray *)[tag objectForKey:@"uids"];

    if (uidArray.count > 0) {
        int threshold = [[tag objectForKey:@"threshold"] intValue];
        int confidence = [[(NSDictionary *)[uidArray objectAtIndex:0] objectForKey:@"confidence"] intValue];
    }
    else {
        return nil;
    }

}

- (void)drawFaces:(NSArray *)tags
{
    

    NSArray *colorArray = [NSArray arrayWithObjects:[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], nil];
    self.squaresArray = [NSMutableArray array];

    //update the labels with the appropriate text.
    NSInteger tagCount = 0;
    for (NSDictionary *tag in tags)
    {
        // You can retrieve individual values using objectForKey on the status NSDictionary
        // This will print the tweet and username to the console
        
        //we only want to draw the square if the face is recognizable..
        NSArray *uidArray = (NSArray *)[tag objectForKey:@"uids"];
        if (uidArray.count > 0) {
        
            int confThresholdDiff = [self findDifferenceBetweenConfidenceAndThresholdForTag:tag];
            
            
        //If the confidence is lower than the threshold, or if its only marginally higher, we'll display it in red (signifying a guess)
            UIColor *chosenColor = [colorArray lastObject];            
            if (confThresholdDiff > -25 && confThresholdDiff <= 10) {
                chosenColor = [colorArray objectAtIndex:0]; //red
            }
            
            if (confThresholdDiff > 10) {
                chosenColor = [colorArray objectAtIndex:1]; //orange
            }
            
            if (confThresholdDiff > 17) {
                chosenColor = [colorArray objectAtIndex:2]; //yellow
            }
            
            if (confThresholdDiff > 25) {
                chosenColor = [colorArray objectAtIndex:3]; //green
                [self learnFromTag:tag];
            }
            
            NSLog(@"The width is %@", [tag objectForKey:@"width"]);
            CGFloat width = ([[tag objectForKey:@"width"] floatValue] * capturedImageView.frame.size.width) / 100;
            CGFloat height = ([[tag objectForKey:@"height"] floatValue] * capturedImageView.frame.size.height) / 100;
            CGFloat x = ([[(NSDictionary *)[tag objectForKey:@"center"] objectForKey:@"x"] floatValue] * capturedImageView.frame.size.width) / 100;
            CGFloat y = ([[(NSDictionary *)[tag objectForKey:@"center"] objectForKey:@"y"] floatValue] * capturedImageView.frame.size.height) / 110; //was /100 before, this is a hack to get images to be vertically aligned properly on someones face.
            
            //CGFloat roll = [[tag objectForKey:@"roll"] floatValue];
            //UIButton *square = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            UIButton *square = [UIButton buttonWithType:UIButtonTypeCustom];
            [square setTag:tagCount];
            square.frame = CGRectMake(0, 0, width, height);
            square.backgroundColor = [UIColor clearColor];
            square.layer.borderWidth = 3.0;
            [square.layer setCornerRadius:8.0f];
            [square.layer setBorderColor:chosenColor.CGColor];
            square.layer.shadowColor = [UIColor whiteColor].CGColor;
            square.layer.shadowRadius = 4;
            square.layer.shadowOpacity = .7;
            square.layer.shadowOffset = CGSizeMake(0, 1);
            square.center = CGPointMake(x, y);
            
            NSLog(@"%@", chosenColor);
            
            //[square setTransform:CGAffineTransformMakeRotation([self DegreesToRadians:roll])];
            
            //This shit here is important - it makes the square clickable.
            square.userInteractionEnabled = YES;
            [square addTarget:self action:@selector(faceTouchUpInside:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
            
            //make sure the square is added as a child to the VIEW instead of the imageView. Otherwise, the imageview will capture all the touch events
            [self.view addSubview:square];
            [self.view bringSubviewToFront:square];
            
            
            self.squareAnimation =[CABasicAnimation animationWithKeyPath:@"opacity"];
            self.squareAnimation.duration=0.5;
            self.squareAnimation.repeatCount=HUGE_VALF;
            self.squareAnimation.autoreverses=YES;
            self.squareAnimation.fromValue=[NSNumber numberWithFloat:1.0];
            self.squareAnimation.toValue=[NSNumber numberWithFloat:0.0];
            
            [self.squaresArray addObject:square];
            [square.layer addAnimation:self.squareAnimation forKey:@"animateOpacity"];
            tagCount += 1;
        }
    
        [self configureFaceLabelWith:tagCount];
        NSLog(@"%d", self.squaresArray.count);
    }
    
}

- (void)faceTouchUpInside:(id)sender {
    NSLog(@"Touch Up Inside Performed");
    [SVProgressHUD showWithStatus:@"Recognizing..." maskType:SVProgressHUDMaskTypeBlack networkIndicator:YES];
    
    UIButton *square = (UIButton *)sender;
    //Crop the face and send it to Parse
    //[self saveDetectedFaceFromImage:self.capturedImage inButton:square];
    
    NSDictionary *tag = [self.detectedFacesTags objectAtIndex:square.tag];
    [self getRecognizedFacebookIdFromTag:tag];
    
    //[self recognizeUsingFaceCom];
    //[self recognize];
    [self performSegueWithIdentifier:@"showPersonViewSegue" sender:nil];
}


/* This method crops whatever is inside the button's frame and sends it to Parse */
- (void)saveDetectedFaceFromImage:(UIImage *)image inButton:(UIButton *)button {
    
    int multiplyer = 4; //this number represents how big the face will be scaled from the original iphone screen size.
    
    CGRect cropRect = button.frame;
    cropRect.size.width = button.frame.size.width * multiplyer;
    cropRect.size.height = button.frame.size.height * multiplyer;
    cropRect.origin.x = button.frame.origin.x * multiplyer;
    cropRect.origin.y = button.frame.origin.y * multiplyer;
        
    CGSize screenSize = CGSizeMake(self.capturedImageView.frame.size.width * multiplyer, self.capturedImageView.frame.size.height * multiplyer);
    
    //scale the image down to an appropriate size.
    UIImage *scaledImage = [image scaledToSize:screenSize];
    
    
    NSLog(@"The croprect width is %f", cropRect.size.width);
    NSLog(@"The croprect height is %f", cropRect.size.height);
    NSLog(@"The croprect x is %f", cropRect.origin.x);
    NSLog(@"The croprect y is %f", cropRect.origin.y);
    NSLog(@"The scaledImage width is %f", scaledImage.size.width);
    NSLog(@"The scaledImage height is %f", scaledImage.size.height);
        
    UIImage *croppedImage = [scaledImage crop:cropRect];
    
    //Store File in Parse
    NSData *scaledImageData = UIImageJPEGRepresentation(croppedImage, 1);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];

    PFFile *imageFile = [PFFile fileWithName:imageName data:scaledImageData];
    
    /*
    UIImageView *croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
    [croppedImageView setFrame:CGRectMake(50.0, 100.0, cropRect.size.width, cropRect.size.height)];
    [[self view] addSubview:croppedImageView];
    [[self view] bringSubviewToFront:croppedImageView];
    */
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            PFObject *userPhoto = [PFObject objectWithClassName:@"DetectedPhoto"];
            
            //setting properties:
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            [userPhoto setObject:[NSNull null] forKey:@"hasBeenRecognized"];
            [userPhoto setObject:[NSNull null] forKey:@"recognizedAs"];
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    NSLog(@"successfully stored a cropped and detected face in Parse");
                    [self setLastParseId:userPhoto.objectId];
                    NSString *urlString = [NSString stringWithFormat:@"http://stormy-moon-8803.herokuapp.com/api/addDetectedImage/%@", userPhoto.objectId];
                    
                    
                    NSLog(@"Url for saving to db: %@", urlString);
                    NSURL *url = [NSURL URLWithString:urlString];
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    //[request setDelegate:self];
                    [request startSynchronous];
                }
                
                else {
                    NSLog(@"Error when saving the cropped and detected face");
                }
            }];
        }
        
        else {
            NSLog(@"Error when saving PFFile - %@", error);
        }
        
    }];
}

- (NSString *)getRecognizedFacebookIdFromTag:(NSDictionary *)tag {
    
    NSLog(@"here's the tag info for the object you tapped: %@", tag);
    
    NSArray *uidArray = (NSArray *)[tag objectForKey:@"uids"];
    NSLog(@"%@", uidArray);
    NSDictionary *recognizedUid = (NSDictionary *)[uidArray objectAtIndex:0];
    NSLog(@"%@", recognizedUid);
    NSArray *namespaceSplit = [[recognizedUid objectForKey:@"uid"] componentsSeparatedByString:@"@"];
    
    NSString *facebookId = [namespaceSplit objectAtIndex:0];
    NSLog(@"%@", facebookId);
    self.retrievedFacebookId = facebookId;
    return facebookId;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
     When a row is selected, the segue creates the detail view controller as the destination.
     Set the detail view controller's detail item to the item associated with the selected row.
     */
    if ([[segue identifier] isEqualToString:@"showPersonViewSegue"]) {
        [SVProgressHUD showWithStatus:@"Loading Profile" maskType:SVProgressHUDMaskTypeBlack networkIndicator:YES];
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
}


#pragma mark - Old Face Recognition Request Delegate Methods

//These are old methods used with our own recognition system.
/*
- (NSURL *) getUrlToQueryFaceComFaceRecognitionWithFacebookId:(NSString *)facebookId andImagePath:(NSString *)imagePath {
    
    //access token hack
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"FBAccessTokenKey"]; 
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.face.com/faces/recognize.json?api_key=f28554fbd62ae04011c90b4895195481&api_secret=e08dc8763856d45e2e479ed4d961b1fa&urls=%@&uids=friends@facebook.com&user_auth=fb_user:%@,fb_oauth_token:%@", imagePath, facebookId, token];
    
    return [NSURL URLWithString:urlString];
}

- (void) recognize {
    
    NSString *urlString = [NSString stringWithFormat:@"http://stormy-moon-8803.herokuapp.com/api/getResultForRecognizedFaceWithId/%@", self.lastParseId];
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
        [self recognize];
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
    
    [SVProgressHUD dismissWithError:@"Recognition Unsuccessful"];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: @"There was an error during the recognition process. Try again?"
                          delegate: nil
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil];
    [alert show];
    
}
 
*/


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set image on imageview and add some rounded corners.
    [self configureView];
    
    //draw the squares around the faces
    self.detectedFacesTags = (NSArray *)[self.retrievedFacesObject objectForKey:@"tags"];
    [self drawFaces:self.detectedFacesTags];
    

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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"squaresArray"]) {
        self.squaresArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"squaresArray"];
        for (UIView *square in self.squaresArray) {
            self.squareAnimation =[CABasicAnimation animationWithKeyPath:@"opacity"];
            self.squareAnimation.duration=0.5;
            self.squareAnimation.repeatCount=HUGE_VALF;
            self.squareAnimation.autoreverses=YES;
            self.squareAnimation.fromValue=[NSNumber numberWithFloat:1.0];
            self.squareAnimation.toValue=[NSNumber numberWithFloat:0.0];
            [square.layer addAnimation:self.squareAnimation forKey:@"animateOpacity"];
        }
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


@end
