//
//  PKDetailViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Parse/Parse.h"


@interface PKDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) UIImage *capturedImage;
@property (nonatomic, retain) NSDictionary *retrievedFacesObject;
@property (nonatomic, retain) IBOutlet UILabel *facesLabel;
@property (nonatomic, retain) IBOutlet UILabel *facesSubTextLabel;
@property (nonatomic, retain) NSString *lastParseId;
@property (nonatomic, retain) NSString *retrievedFacebookId;
@property (nonatomic, retain) NSArray *detectedFacesTags;
@property (nonatomic, retain) NSMutableArray *squaresArray;
@property (nonatomic, retain) CABasicAnimation *squareAnimation;
- (void)drawFaces:(NSArray *)tags;
- (void)faceTouchUpInside:(id)sender;
- (void)configureView;
- (void)configureFaceLabelWith:(int)numberOfFaces;
- (void)recognize;
- (void) recognizeUsingFaceCom;
- (void)saveDetectedFaceFromImage:(UIImage *)image inButton:(UIButton *)button;
- (NSString *)getRecognizedFacebookIdFromTag:(NSDictionary *)tag;
@end
