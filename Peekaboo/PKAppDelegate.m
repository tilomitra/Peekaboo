//
//  PKAppDelegate.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKAppDelegate.h"
#import "PKMasterViewController.h"
#import "PKFacebookConnectViewController.h"
//static NSString* APP_ID = @"210849718975311";
static NSString *APP_ID = @"131590113628423";

@implementation UINavigationBar (UINavigationBarCategory)
/*
- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"redTopBar.png"];
    [img drawInRect:rect];
}
 */
@end


@implementation PKAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize facebook;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //PKMasterViewController *controller = (PKMasterViewController *)navigationController.topViewController;
    
    //PKMasterViewController *masterVC = [navigationController.storyboard instantiateViewControllerWithIdentifier:@"masterViewController"];
    //controller.managedObjectContext = self.managedObjectContext;
    //PKMaster *custom = [navController.storyboard instantiateViewControllerWithIdentifier:@"CustomController"];
    
    // First item in array is bottom of stack, last item is top.
    //navigationController.viewControllers = [NSArray arrayWithObjects:masterVC, nil];
    
    //[navigationController popToViewController:controller animated:YES];
    //[self.window makeKeyAndVisible];
    
    // Create resizable images
    //UIImage *gradientImage44 = [[UIImage imageNamed:@"topbar"] 
    //                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //UIImage *gradientImage32 = [[UIImage imageNamed:@"topbar32"] 
    //                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
   // Set the background image for *all* UINavigationBars
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage44 
    //                                   forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundImage:gradientImage32 
    //                                   forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    
    
    //Facebook Authentication
    facebook = [[Facebook alloc] initWithAppId:APP_ID andDelegate:self];

    return YES;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Facebook Custom Implemented Methods


- (void) checkDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults removeObjectForKey:@"FBAccessTokenKey"];
    //[defaults removeObjectForKey:@"FBExpirationDateKey"];
    //[facebook logout];
    
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        
        NSLog(@"token given with id %@", [defaults objectForKey:@"FBAccessTokenKey"]);
        NSLog(@"token expiration date given %@", [defaults objectForKey:@"FBExpirationDateKey"]);

    }
    
    if (![facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes",
                                //@"user_birthday",
                                //@"user_location",
                                @"user_about_me",
                                //@"user_hometown",
                                //@"user_work_history",
                                @"user_photos",
                                @"offline_access",
                                nil];
        [[self facebook] authorize:permissions];
    }

}

- (BOOL) isSignedIn {
    return [[self facebook] isSessionValid];
}

- (void) logoutFromFacebook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [[self facebook] logout];
}




#pragma mark - Facebook Delegate Methods
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[self facebook] handleOpenURL:url]; 
}


// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[self facebook] handleOpenURL:url]; 
}


- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];

}


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
    
    NSString *requestType =[request.url stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
    NSLog(@"request %@",requestType); 
    
    
    NSLog(@"Request did load");
    NSLog(@"%@", result);
}

/*
 May want to implement this to handle the processing of the server data if you need access to the raw response.
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    
}
 */


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Peekaboo" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Peekaboo.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
