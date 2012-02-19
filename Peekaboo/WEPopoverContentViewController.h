//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WEPopoverContentViewController : UITableViewController {
    NSArray *itemArray;
}

@property (nonatomic, retain) NSArray *itemArray;

- (id)initWithStyle:(UITableViewStyle)style passArray:(NSArray*)myArray;
@end
