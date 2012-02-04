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

//fql?q=SELECT cover_object_id FROM album WHERE aid IN (SELECT aid, name FROM album WHERE owner=501146691 AND name='Cover Photos')
static NSString *fbCoverPhotoCall = @"fql?q=SELECT%20cover_object_id%20from%20album%20where%20aid%20IN%20(SELECT%20aid,%20name%20FROM%20album%20WHERE%20owner=%20501146691%20and%20name='Cover%20Photos')";

@implementation PersonViewController
@synthesize dismissButton;
@synthesize facebookId;
@synthesize person;
@synthesize coverPhotoId;

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
    
    if ([requestType isEqualToString:@"me"]) {
        [[self person] setData:result];
    }
    
    else if ([requestType isEqualToString:@"me/likes"]) {
        [[self person] categorizeLikes:result];
    }
    
    else if ([requestType isEqualToString:fbCoverPhotoCall]) {
        //Get the cover_object_id and send another request to get the photo
        NSArray *data = (NSArray *)[result objectForKey:@"data"];
        NSDictionary *o = (NSDictionary *)[data lastObject]; //this will be the only object in there.
        self.coverPhotoId = [NSString stringWithString:[o objectForKey:@"cover_object_id"]];
        [[delegate facebook] requestWithGraphPath:self.coverPhotoId andDelegate:self];
    }
    
    else if ([requestType isEqualToString:self.coverPhotoId]) {
        [[self person] setCoverPhotoFromData:result];
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
    
    [[delegate facebook] requestWithGraphPath:@"me" andDelegate:self];
    [[delegate facebook] requestWithGraphPath:@"me/likes" andDelegate:self];
    
    //get cover photo
    [[delegate facebook] requestWithGraphPath:fbCoverPhotoCall andDelegate:self];
    
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
