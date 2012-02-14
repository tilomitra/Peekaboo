//
//  AsynchronousImageView.m
//  WallApp
//
//  Created by sebastiao Gazolla Costa Junior on 10/06/11.
//  Based on http://iphone-dev-tips.alterplay.com/2009/10/asynchronous-uiimage.html 

#import "AsynchronousUIImage.h"


@implementation AsynchronousUIImage
@synthesize delegate;
@synthesize tag;

- (void)loadImageFromURL:(NSURL *)anUrl {
    NSURLRequest *request = [NSURLRequest requestWithURL:anUrl 
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                         timeoutInterval:30.0];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];
    
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
    [self initWithData:data];
    //[data release], 
    data = nil;
    //[connection release], 
    connection = nil;    
    [self.delegate imageDidLoad:self];
}

-(void)dealloc{
    //[super dealloc];
    connection = nil;
    data = nil;
}

@end
