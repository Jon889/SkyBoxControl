//
//  UFContentDirectoryService.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 14/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFService.h"
@class UFContainer;
@interface UFContentDirectoryService : UFService
-(void)fetchRootContainers:(void (^)(NSArray* subObjects, NSInteger numberReturned, NSInteger totalMatches, NSError* error))handler;
-(void)browseContainer:(UFContainer *)container startingIndex:(NSInteger)si completion:(void (^)(NSArray* subObjects, NSInteger numberReturned, NSInteger totalMatches, NSError* error))handler;
@end
