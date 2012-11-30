//
//  SBCPlannerModel.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 17/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBCPlannerModel : NSObject
@property (nonatomic, strong) NSArray *baseItems;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic, strong) NSArray *currentItems;
-(void)groupByKey:(NSString*)key;
-(NSUInteger)numberOfItems;
-(id)objectAtIndex:(NSInteger)index;
@end
