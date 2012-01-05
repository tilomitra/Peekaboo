//
//  main.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-01-01.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKAppDelegate.h"
#import "Parse/Parse.h"

int main(int argc, char *argv[])
{
    [Parse setApplicationId:@"DOCKNIyEg5jGqZFj18sBxJOTXvYCQjryFDCrD35G" 
                  clientKey:@"KuOvNtvcP4B6eYHySdOcpU0WiA13wjPzHVhQFheq"];
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PKAppDelegate class]));
    }
}
