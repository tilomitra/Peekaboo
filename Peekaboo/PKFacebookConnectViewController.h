//
//  PKFacebookConnectViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-17.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface PKFacebookConnectViewController : UIViewController <FBSessionDelegate> {
    IBOutlet UIButton *facebookConnectButton;
    Facebook *facebook;

    
}

@property (nonatomic, retain) IBOutlet UIButton *facebookConnectButton;
@property (nonatomic, retain) Facebook *facebook;

//- (IBAction)facebookButtonSelected:(id)sender;
- (void)fbDidLogin;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
@end
