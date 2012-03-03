//
//  PKSettingsViewController.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-03-02.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKSettingsViewController : UITableViewController {
    NSArray *settingsArray;
}

@property (nonatomic, retain) NSArray *settingsArray;

@end
