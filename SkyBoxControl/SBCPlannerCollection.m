//
//  SBCPlannerModel.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 17/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCPlannerCollection.h"

@implementation SBCPlannerCollection
-(NSMutableArray *)backingArray {
	if (!_backingArray) {
		_backingArray = [[NSMutableArray alloc] init];
	}
	return _backingArray;
}
-(id)forwardingTargetForSelector:(SEL)aSelector {
	if ([NSStringFromSelector(aSelector) isEqualToString:self.groupingKey]) {
		return [self objectAtIndex:0];
	} else {
		return [super forwardingTargetForSelector:aSelector];
	}
}
-(void)addObject:(id)object {
	[self.backingArray addObject:object];
}
-(id)objectAtIndex:(NSUInteger)index {
	return [self.backingArray objectAtIndex:index];
}
-(NSUInteger)numberOfItems {
	return self.backingArray.count;
}
-(NSString *)latestScheduleTimeInCollection {
	id currentLatest = nil;
	for (id obj in self.backingArray) {
		if ([[NSSortDescriptor sortDescriptorWithKey:@"scheduledStartTime" ascending:YES] compareObject:currentLatest toObject:obj] == NSOrderedAscending) {
			currentLatest = obj;
		}
	}
	return [currentLatest valueForKey:@"scheduledStartTime"];
}
@end
