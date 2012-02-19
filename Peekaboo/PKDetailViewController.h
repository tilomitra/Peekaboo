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
@property (nonatomic, retain) IBOutlet UIButton *tempRecognizeButton;
@property (nonatomic, retain) NSString *lastParseId;
@property (nonatomic, retain) NSString *retrievedFacebookId;
- (void)drawFaces:(NSArray *)tags;
- (void)faceTouchUpInside:(id)sender;
- (void)configureView;
- (void)configureFaceLabelWith:(int)numberOfFaces;
- (void)checkIfRecognized;

@end
