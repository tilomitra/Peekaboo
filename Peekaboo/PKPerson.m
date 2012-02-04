//
//  PKPerson.m
//  Peekaboo
//
//  Created by Tilo Mitra on 12-02-04.
//  Copyright (c) 2012 University of Waterloo. All rights reserved.
//

#import "PKPerson.h"

@implementation PKPerson

@synthesize fbId;
@synthesize name;
@synthesize fbLink;
@synthesize gender;
@synthesize location;
@synthesize favoriteTeams;
@synthesize favoriteAthletes;
@synthesize quotes;

@synthesize likes;
@synthesize coverPhotoUrl;

- (id) init {
    
    self.fbId = @"";
    self.name = @"";
    self.fbLink = @"";
    self.gender = @"";
    self.location = [NSDictionary dictionary];
    self.favoriteTeams = [NSArray array];
    self.favoriteAthletes = [NSArray array];
    self.quotes = @"";
    self.likes = [NSDictionary dictionary];

    return self;
}


- (void) setData:(NSDictionary *)data {
    
    if ([data objectForKey:@"id"]) {
        self.fbId = [data objectForKey:@"id"];
    }
    
    if ([data objectForKey:@"name"]) {
        self.name = [data objectForKey:@"name"];
    }
    
    if ([data objectForKey:@"link"]) {
        self.fbLink = [data objectForKey:@"link"];
    }
    
    if ([data objectForKey:@"name"]) {
        self.gender = [data objectForKey:@"gender"];
    }
    
    if ([data objectForKey:@"location"]) {
        self.location = [data objectForKey:@"location"];
    }
    
    if ([data objectForKey:@"favourite_teams"]) {
        self.favoriteTeams = [data objectForKey:@"favourite_teams"];
    }
    
    if ([data objectForKey:@"favourite_athletes"]) {
        self.favoriteAthletes = [data objectForKey:@"favourite_athletes"];
    }
    
    if ([data objectForKey:@"quotes"]) {
        self.quotes = [data objectForKey:@"quotes"];
    }
}

/*
This method takes a NSDictionary of likes returned by facebook and returns an NSMutableDictionary of NSArrays, where
each key in the dictionary corresponds with a "category"

 For example: 
    { 
        "company": [{} , {} , {} ], 
        "song": [ {} , {} ] 
    } 
 
 */
- (void) categorizeLikes:(NSDictionary *)likesData {
    NSArray *allLikes = (NSArray *)[likesData objectForKey:@"data"];
    
    NSMutableDictionary *sortedLikes = [NSMutableDictionary dictionary];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:allLikes];
    
    for (likes in tempArray) {
        NSString *catKey = [likes objectForKey:@"category"];
        
        //If the dictionary already has this category defined, then there is a NSMutableArray inside it
        //and we can just push this object into that array
        if ([sortedLikes objectForKey:catKey] != nil) {
            [[sortedLikes objectForKey:catKey] addObject:likes];
        }
        
        //Otherwise, if the dictionary does not have this category defined,
        //we must create a NSMutableArray and add it to this category with that object inside it.
        else {
            NSMutableArray *catArray = [NSMutableArray arrayWithObject:likes];
            [sortedLikes setObject:catArray forKey:catKey];
        }
        
    }
    
    self.likes = sortedLikes;
}


- (void) setCoverPhotoFromData:(NSDictionary *)data {
    NSLog(@"%@", data);
    NSString *url = [[[data objectForKey:@"images"] objectAtIndex:0] objectForKey:@"source"];
    self.coverPhotoUrl = [NSURL URLWithString:url];
}
@end
