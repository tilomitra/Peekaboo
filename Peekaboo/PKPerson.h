//
//  PKPerson.h
//  Peekaboo
//
//  Created by Tilo Mitra on 12-02-04.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKPerson : NSObject {
    NSString *fbId;
    NSString *name;
    NSString *fbLink;
    NSString *gender;
    
    NSDictionary *location;
    NSArray *favoriteTeams;
    NSArray *favoriteAthletes;
    
    NSString *quotes;
    
    NSDictionary *likes;
    
    NSURL *coverPhotoUrl;
    
    
    
}
    
@property (nonatomic, retain) NSString *fbId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fbLink;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSDictionary *location;
@property (nonatomic, retain) NSArray *favoriteTeams;
@property (nonatomic, retain) NSArray *favoriteAthletes;
@property (nonatomic, retain) NSString *quotes;
@property (nonatomic, retain) NSDictionary *likes;
@property (nonatomic, retain) NSURL *coverPhotoUrl;

- (id) init;
- (void) setData:(NSDictionary *)data;
- (void) categorizeLikes:(NSDictionary *)likesData;
- (void) setCoverPhotoFromData:(NSDictionary *)data;
@end
