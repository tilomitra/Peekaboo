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
//fql?q=SELECT cover_object_id FROM album WHERE aid IN (SELECT aid, name FROM album WHERE owner=501146691 AND name='Cover Photos')
static NSString *fbCoverPhotoCall = @"fql?q=SELECT%20cover_object_id%20from%20album%20where%20aid%20IN%20(SELECT%20aid,%20name%20FROM%20album%20WHERE%20owner=%20501146691%20and%20name='Cover%20Photos')";

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
    NSLog(@"request did receive response");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@", [error userInfo]);
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    PKAppDelegate *delegate = (PKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    NSLog(@"%@", requestType);
    
    
    //Basic User Info
    if ([requestType isEqualToString:@"me"]) {
        NSLog(@"%@", result);
        [[self person] setData:result];
        [[self nameLabel] setText:self.person.name];
        [[self navigationController] setTitle:self.person.name];
        [[self secondaryInfoLabel] setText:[self.person.location objectForKey:@"name"]];
    }
    
    //Likes of a person
    else if ([requestType isEqualToString:@"me/likes"]) {
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
    
    else if ([requestType isEqualToString:@"me/picture?type=large"]) {
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    
    //get cover photo
    [[delegate facebook] requestWithGraphPath:fbCoverPhotoCall andDelegate:self];
    
    
    [[delegate facebook] requestWithGraphPath:@"me" andDelegate:self];
    [[delegate facebook] requestWithGraphPath:@"me/likes" andDelegate:self];
    [[delegate facebook] requestWithGraphPath:@"me/picture?type=large" andDelegate:self];
    


    
}

/*
- (void)viewWillAppear:(BOOL)animated {

}
*/

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

@end
