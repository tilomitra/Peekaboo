//
//  PKAppDelegate.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface PKAppDelegate : UIResponder <UIApplicationDelegate, FBRequestDelegate> {
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//Facebook Methods
- (void) checkDefaults;
- (BOOL) isSignedIn;
- (void) logoutFromFacebook;
@end
