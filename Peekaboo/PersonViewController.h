//
//  PersonViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-14.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FBConnect.h"
#import "PKPerson.h"
#import "AsynchronousUIImage.h"
@interface PersonViewController : UIViewController <FBRequestDelegate, AsynchronousUIImageDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSString *facebookId;
    PKPerson *person;
    IBOutlet UIImageView *coverPhotoView;
    IBOutlet UIImageView *profilePictureView;
    IBOutlet UITableView *tableView;
    
    //Labels
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *secondaryInfoLabel;

    //hack
    NSString *coverPhotoId;
}


@property (nonatomic, retain) IBOutlet UIButton *dismissButton;
@property (nonatomic, retain) NSString *facebookId;
@property (nonatomic, retain) PKPerson *person;
@property (nonatomic, retain) IBOutlet UIImageView *coverPhotoView;
@property (nonatomic, retain) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, retain) NSString *coverPhotoId;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *secondaryInfoLabel;

- (void) displayCoverPhoto;

@end
