//
//  SBCPlannerModel.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 17/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBCPlannerCollection : NSObject
@property (nonatomic, strong) NSString *groupingKey;
@property (nonatomic, strong) NSMutableArray *backingArray;
-(NSUInteger)numberOfItems;
-(id)objectAtIndex:(NSUInteger)index;
-(void)addObject:(id)object;
@end
