//
//  AsyncImageView.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-02-05.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView {
    //could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to 
	// to build into this class?
    
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
}

- (void)loadImageFromURL:(NSURL*)url;
- (UIImage*) image;

@end
