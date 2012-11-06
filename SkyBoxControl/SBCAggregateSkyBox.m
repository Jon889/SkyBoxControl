//
//  SBCDevice.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCAggregateSkyBox.h"
#import "UFDevice.h"
#import "UFService.h"

@implementation SBCAggregateSkyBox
-(id)init {
	if (self = [super init]) {
		self.devices = [NSMutableArray array];
	}
return self;
}
-(NSString *)description {
	return [NSString stringWithFormat:@"%li", self.devices.count];
}
-(NSString *)title {
	return [(NSURL *)[NSURL URLWithString:((id)[self.devices[0] response])[@"LOCATION"]] host];
}
-(UFService *)serviceForType:(NSString *)serviceType {
	NSMutableArray *serviceCollector = [NSMutableArray array];
	for (UFDevice *device in self.devices) {
		UFService *service = [device serviceForType:serviceType];
		if (service) {
			[serviceCollector addObject:service];
		}
	}
	if ([serviceCollector count] > 1) {
		NSLog(@"More than one service found with name: %@", serviceType);
	}
	return ([serviceCollector count] > 0) ? serviceCollector[0] : nil;
}
-(UFService *)serviceForId:(NSString *)serviceId {
	NSMutableArray *serviceCollector = [NSMutableArray array];
	for (UFDevice *device in self.devices) {
		UFService *service = [device serviceForId:serviceId];
		if (service) {
			[serviceCollector addObject:service];
		}
	}
	if ([serviceCollector count] > 1) {
		NSLog(@"More than one service found with name: %@", serviceId);
	}
	return ([serviceCollector count] > 0) ? serviceCollector[0] : nil;
}

-(UFService *)skyPlayService {
	return [self serviceForId:@"urn:nds-com:serviceId:SkyPlay2"];
}
@end
