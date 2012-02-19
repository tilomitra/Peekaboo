//
//  PersonViewController.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-14.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PersonViewController.h"
#import "PKAppDelegate.h"
#import "PKPerson.h"
#import "AsynchronousUIImage.h"

#import "WEPopoverContentViewController.h"
#import "UIBarButtonItem+WEPopover.h"



//fql?q=SELECT cover_object_id FROM album WHERE aid IN (SELECT aid, name FROM album WHERE owner=501146691 AND name='Cover Photos')

@implementation PersonViewController
@synthesize dismissButton;
@synthesize facebookId;
@synthesize person;
@synthesize coverPhotoView;
@synthesize coverPhotoId;
@synthesize profilePictureView;
@synthesize tableView;
@synthesize nameLabel;
@synthesize secondaryInfoLabel;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //coverPhotoView = [[AsyncImageView alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Facebook Request Delegate Methods


- (void)requestLoading:(FBRequest *)request {
    NSLog(@"Request Loading");
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"request did receive response with url %@", request.url);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"the current token is %@", [defaults objectForKey:@"FBAccessTokenKey"]);
    NSLog(@"the current token expiration date is %@", [defaults objectForKey:@"FBExpirationDateKey"]);
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@", [error userInfo]);
}

- (void)request:(FBRequest *)request didLoad:(id)result {

    
    PKAppDelegate *delegate = (PKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    NSLog(@"%@", requestType);
    
    //access token hack
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"FBAccessTokenKey"];  
    
    NSString *fbCoverPhotoCall = [NSString stringWithFormat:@"%@%@%@&access_token=%@", @"fql?q=SELECT%20cover_object_id%20from%20album%20where%20aid%20IN%20(SELECT%20aid,%20name%20FROM%20album%20WHERE%20owner=", self.facebookId, @"%20and%20name='Cover%20Photos')", token];
    
    NSLog(@"%@", fbCoverPhotoCall);
    
    //Basic User Info
    if ([requestType isEqualToString:[NSString stringWithFormat:@"%@&access_token=%@", self.facebookId, token]]) {
        NSLog(@"%@", result);
        [[self person] setData:result];
        [[self nameLabel] setText:self.person.name];
        [[self navigationController] setTitle:self.person.name];
        [[self secondaryInfoLabel] setText:[self.person.location objectForKey:@"name"]];
    }
    
    //Likes of a person
    else if ([requestType isEqualToString:[NSString stringWithFormat:@"%@/likes&access_token=%@", self.facebookId, token]]) {
        [[self person] categorizeLikes:result];
        [[self tableView] reloadData];
    }
    
    
    //Cover Photo FQL Query that returns cover_photo_id
    else if ([requestType isEqualToString:fbCoverPhotoCall]) {
        //Get the cover_object_id and send another request to get the photo
        NSArray *data = (NSArray *)[result objectForKey:@"data"];
        NSDictionary *o = (NSDictionary *)[data lastObject]; //this will be the only object in there.
        self.coverPhotoId = [NSString stringWithString:[o objectForKey:@"cover_object_id"]];
        [[delegate facebook] requestWithGraphPath:self.coverPhotoId andDelegate:self];
    }
    
    //Cover Photo Image URL
    else if ([requestType isEqualToString:self.coverPhotoId]) {
        [[self person] setCoverPhotoFromData:result];
        [self displayCoverPhoto];
    }
    
    else if ([requestType isEqualToString:[NSString stringWithFormat:@"%@/picture?type=large&access_token=%@", self.facebookId, token]]) {
        self.profilePictureView.image = [UIImage imageWithData:result];
    }
}

#pragma mark - Display Methods

- (void) displayCoverPhoto {
    AsynchronousUIImage *coverImage = [[AsynchronousUIImage alloc] init];
    
    [coverImage loadImageFromURL:self.person.coverPhotoUrl];
    
    coverImage.tag = 1;
    coverImage.delegate = self;
    
}

#pragma mark - Async Image Delegate Methods

-(void) imageDidLoad:(AsynchronousUIImage *)anImage{
    if (anImage.tag == 1) {
        coverPhotoView.image = anImage;
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
    [super viewDidLoad];
    
    PKAppDelegate *delegate = (PKAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.person = [[PKPerson alloc] init];
    
    if (!self.facebookId) {
        self.facebookId = @"541904540";
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Access Token Hack
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"FBAccessTokenKey"];    
    
    
    NSLog(@"the person's facebook ID is %@", self.facebookId);
    
    NSString *fbCoverPhotoCall = [NSString stringWithFormat:@"%@%@%@&access_token=%@", @"fql?q=SELECT%20cover_object_id%20from%20album%20where%20aid%20IN%20(SELECT%20aid,%20name%20FROM%20album%20WHERE%20owner=", self.facebookId, @"%20and%20name='Cover%20Photos')", token];

    
    //get cover photo
    [[delegate facebook] requestWithGraphPath:fbCoverPhotoCall andDelegate:self];
    
    
    [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@&access_token=%@", self.facebookId, token] andDelegate:self];
    [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/likes&access_token=%@", self.facebookId, token] andDelegate:self];
    [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/picture?type=large&access_token=%@", self.facebookId, token] andDelegate:self];
    
    
    popoverClass = [WEPopoverController class];
    currentPopoverCellIndex = -1;

    
}

/*
- (void)viewWillAppear:(BOOL)animated {

}
*/

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[self.popoverController dismissPopoverAnimated:NO];
	self.popoverController = nil;
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *keys = [[person likes] allKeys];
    return [keys count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSArray *keys = [[person likes] allKeys];
    cell.textLabel.text = [keys objectAtIndex:[indexPath row]];
    
    //NSInteger section = [indexPath section];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	BOOL shouldShowNewPopover = indexPath.row != currentPopoverCellIndex;
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
		currentPopoverCellIndex = -1;
	} 
	
	if (shouldShowNewPopover) {
		//UIViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
        
        NSArray *keys = [[person likes] allKeys];
        NSString *key = [keys objectAtIndex:[indexPath row]];
        NSArray *detailArray = [[person likes] objectForKey:key];
        
        UIViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain passArray:detailArray];
        
        //contentViewController.itemArray = [NSArray arrayWithObjects:@"Test1", @"Test2", nil];
        
        
		//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
        
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]]; 

        //NSLog(@"Cell Width = %f", rectInSuperview.size.width);
        //NSLog(@"Cell Height = %f",rectInSuperview.size.height);
        //NSLog(@"Cell Origin X = %f",rectInSuperview.origin.x);
        //NSLog(@"Cell Origin Y = %f",rectInSuperview.origin.y);
		
		self.popoverController = [[popoverClass alloc] initWithContentViewController:contentViewController];
		
		if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
			[self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
		}
		
		self.popoverController.delegate = self;
		
		//Uncomment the line below to allow the table view to handle events while the popover is displayed.
		//Otherwise the popover is dismissed automatically if a user touches anywhere outside of its view.
		
		self.popoverController.passthroughViews = [NSArray arrayWithObject:self.tableView];
		
		[self.popoverController presentPopoverFromRect:rectInSuperview  
												inView:self.view 
							  permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown|
														UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight)
											  animated:YES];
		currentPopoverCellIndex = indexPath.row;
		
	}
	
}



#pragma mark - Popover Methods


- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] init];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin; 
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;	
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}


@end
