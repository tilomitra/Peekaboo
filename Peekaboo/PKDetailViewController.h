//
//  PKDetailViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PKDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) UIImage *capturedImage;
@property (nonatomic, retain) NSDictionary *retrievedFacesObject;
@property (nonatomic, retain) IBOutlet UILabel *facesLabel;
@property (nonatomic, retain) IBOutlet UILabel *facesSubTextLabel;


- (void)drawFaces:(NSArray *)tags;

@end
