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
@interface PersonViewController : UIViewController <FBRequestDelegate> {
    NSString *facebookId;
    PKPerson *person;
    
    //hack
    NSString *coverPhotoId;
}


@property (nonatomic, retain) IBOutlet UIButton *dismissButton;
@property (nonatomic, retain) NSString *facebookId;
@property (nonatomic, retain) PKPerson *person;

@property (nonatomic, retain) NSString *coverPhotoId;


@end
