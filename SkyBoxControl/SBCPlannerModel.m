//
//  SBCPlannerModel.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 17/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCPlannerModel.h"
#import "SBCPlannerCollection.h"
@implementation SBCPlannerModel
-(NSArray *)filteredItems {
	if (!_filteredItems) {
		_filteredItems = self.baseItems;
	}
	return _filteredItems;
}
-(void)groupByKey:(NSString*)key {
	NSMutableDictionary *groups = [NSMutableDictionary dictionary];
	for (id obj in self.filteredItems) {
		NSString *groupingValue = [obj valueForKey:key];
		SBCPlannerCollection *group = [groups objectForKey:groupingValue];
		if (!group) {
			group = [[SBCPlannerCollection alloc] init];
			[group setGroupingKey:key];
			[groups setObject:group forKey:groupingValue];
		}
		[group addObject:obj];
	}
	self.currentItems = [[groups allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"latestScheduleTimeInCollection" ascending:YES]]];
}
-(NSUInteger)numberOfItems {
	return (self.currentItems) ? self.currentItems.count : self.baseItems.count;
}
-(id)objectAtIndex:(NSInteger)index {
	return (self.currentItems) ? self.currentItems[index] : self.baseItems[index];
}

@end
