//
//  PKFacebookConnectViewController.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-17.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKFacebookConnectViewController.h"
#import "PKMasterViewController.h"
#import "PKAppDelegate.h"
#import "PKMasterViewController.h"
#import "PKTrainingViewController.h"

@implementation PKFacebookConnectViewController

@synthesize facebookConnectButton;
@synthesize facebook;


- (BOOL) didUserTrain
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UserTrained"];
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


- (IBAction)facebookButtonSelected:(id)sender {
    
    PKAppDelegate *delegate = (PKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate checkDefaults];
    
    BOOL userTrained = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserTrained"];
    
    if (userTrained == YES) {
        //Go to Master View
        //PKMasterViewController* masterVC = [[PKMasterViewController alloc] init];
        [self performSegueWithIdentifier:@"userTrainedMasterSegue" sender:nil];
    }
    
    else if (userTrained == NO) {
        //Go to Training View
        [self performSegueWithIdentifier:@"userNotTrainedTrainingSegue" sender:nil];

    }
    
//We have access tokens so push them through to the next view.
//    PKMasterViewController* masterVC = [[PKMasterViewController alloc] init];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterVC];   
//    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentModalViewController:navigationController animated:YES];
//[self performSegueWithIdentifier:@"facebookButtonPressedSegue" sender:self]; 
  
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"userTrainedMasterSegue"]) {
        PKMasterViewController *masterVC = [segue destinationViewController];
    }
    
    else if ([[segue identifier] isEqualToString:@"userNotTrainedTrainingSegue"]) {
        PKTrainingViewController *trainingVC = [segue destinationViewController];
    }
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
    // Setting up training user defaults if they don't already exist 
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"UserTrained"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UserTrained"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    //[self performSegueWithIdentifier:@"facebookButtonPressedSegue" sender:self];
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
