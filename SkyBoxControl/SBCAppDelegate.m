//
//  SBCAppDelegate.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCAppDelegate.h"
#import "SBCDiscoverer.h"
#import "SBCAggregateSkyBox.h"
#import "PXSourceList.h"
#import "UFControlPoint.h"
#import "UFDevice.h"

@interface SBCAppDelegate () <UFControlPointDelegate, PXSourceListDataSource, PXSourceListDelegate>{
	UFControlPoint *cp;
}
@property (nonatomic, strong) NSMutableArray *filteredDevices;
@end
@implementation SBCAppDelegate
- (IBAction)rwButtonClicked:(id)sender {
//	SBCAggregateSkyBox *skyBox = [self.filteredDevices objectAtIndex:self.sourceList.selectedRow -1 ];
//	[[[skyBox skyPlayService] actionForName:@"Play"] postWithArgumentDictionary:@{@"InstanceID" : @"0", @"Speed" : @"-2"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
//		NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
//	}];
	SBCAggregateSkyBox *skyBox = [self.filteredDevices objectAtIndex:self.sourceList.selectedRow-1];
	[[[skyBox skyPlayService] actionForName:@"GetTransportInfo"] postWithArgumentDictionary:@{@"InstanceID" : @"0"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:d options:NSXMLNodeOptionsNone error:nil];
		NSError *err = nil;
		NSXMLNode *node = [doc nodesForXPath:@"//s:Envelope/s:Body/*[local-name() = 'GetTransportInfoResponse']/CurrentSpeed" error:&err][0];
		NSInteger currentSpeed = [[node stringValue] integerValue];
		NSInteger newSpeed = [self speedForCurrentSpeed:currentSpeed fastForward:NO];
		[[[skyBox skyPlayService] actionForName:@"Play"] postWithArgumentDictionary:@{@"InstanceID" : @"0", @"Speed" : [NSString stringWithFormat:@"%li", newSpeed]} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
			NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
		}];
	}];
}
- (IBAction)playButtonClicked:(id)sender {
	SBCAggregateSkyBox *skyBox = [self.filteredDevices objectAtIndex:self.sourceList.selectedRow -1 ];
	[[[skyBox skyPlayService] actionForName:@"Play"] postWithArgumentDictionary:@{@"InstanceID" : @"0", @"Speed" : @"1"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
	}];
}
- (IBAction)ffButtonClicked:(id)sender {
	
	SBCAggregateSkyBox *skyBox = [self.filteredDevices objectAtIndex:self.sourceList.selectedRow-1];
	[[[skyBox skyPlayService] actionForName:@"GetTransportInfo"] postWithArgumentDictionary:@{@"InstanceID" : @"0"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:d options:NSXMLNodeOptionsNone error:nil];
		NSError *err = nil;
		NSXMLNode *node = [doc nodesForXPath:@"//s:Envelope/s:Body/*[local-name() = 'GetTransportInfoResponse']/CurrentSpeed" error:&err][0];
		NSInteger currentSpeed = [[node stringValue] integerValue];
		NSInteger newSpeed = [self speedForCurrentSpeed:currentSpeed fastForward:YES];
		[[[skyBox skyPlayService] actionForName:@"Play"] postWithArgumentDictionary:@{@"InstanceID" : @"0", @"Speed" : [NSString stringWithFormat:@"%li", newSpeed]} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
			NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
		}];
	}];
	
	
}
- (IBAction)pauseButtonClicked:(id)sender {
	
	SBCAggregateSkyBox *skyBox = [self.filteredDevices objectAtIndex:self.sourceList.selectedRow-1];
	[[[skyBox skyPlayService] actionForName:@"GetMediaInfo_Ext"] postWithArgumentDictionary:@{@"InstanceID" : @"0"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
	}];
}
-(NSInteger)speedForCurrentSpeed:(NSInteger)cs fastForward:(BOOL)ff {
	int modifier = (ff) ? 1 : -1;
	if (30 == modifier * cs) {
		return cs;
	}
	if (cs == modifier * -30) {
			return modifier * -12;
	}
	if (cs == modifier * -12) {
			return modifier * -6;
	}
	if (cs == modifier * -6) {
			return modifier * -2;
	}
	if (cs == modifier * -2) {
			return modifier * 1;
	}
	if (cs == 1) {
			return modifier * 2;
	}
	if (cs == modifier * 2) {
			return modifier * 6;
	}
	if (cs == modifier * 6) {
			return modifier * 12;
	}
	if (cs == modifier * 12) {
			return modifier * 30;
	}
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.filteredDevices = [NSMutableArray array];
	//	SBCDiscoverer *disc = [[SBCDiscoverer alloc] init];
	//	[disc setDelegate:self];
	//	[disc startDiscovery];
	cp = [[UFControlPoint alloc] init];
	[cp setDelegate:self];
	[cp startSearching];
}
-(void)controlPoint:(UFControlPoint *)controlPoint discoveredDevice:(UFDevice *)newDevice {
	
	//-(void)discoverer:(SBCDiscoverer *)discoverer discoveredService:(SBCResponse *)service {
	//	NSLog(@"%@", service);
	BOOL hasBeenAdded = NO;
	for (SBCAggregateSkyBox *skyBox in self.filteredDevices) {
		if ([newDevice.response isSameHostToResponse:[(UFDevice *)skyBox.devices[0] response]]) {
			[skyBox.devices addObject:newDevice];
			hasBeenAdded = YES;
		}
	}
	if (!hasBeenAdded) {
		SBCAggregateSkyBox *skyBox = [[SBCAggregateSkyBox alloc] init];
		[skyBox.devices addObject:newDevice];
		[self.filteredDevices addObject:skyBox];
	}
	[self.sourceList reloadData];
}
-(NSUInteger)sourceList:(PXSourceList *)sourceList numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return 1;
	}
	return [self.filteredDevices count];
}
-(id)sourceList:(PXSourceList *)aSourceList child:(NSUInteger)index ofItem:(id)item {
	if (item == nil) {
		return @"BOXES";
	}
	return [self.filteredDevices objectAtIndex:index];
}
-(id)sourceList:(PXSourceList *)aSourceList objectValueForItem:(id)item {
	if ([item isKindOfClass:[NSString class]]) {
		return item;
	} else {
		return [item title];
	}
}
- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item {
	return [item isKindOfClass:[NSString class]];
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group {
	return YES;
}
- (BOOL)sourceList:(PXSourceList*)aSourceList shouldEditItem:(id)item {
	return NO;
}
- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasIcon:(id)item {
	return YES;
}
- (NSImage*)sourceList:(PXSourceList*)aSourceList iconForItem:(id)item {
	return [NSImage imageNamed:@"SkyBoxIcon"];
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification {
	NSIndexSet *selectedIndexes = [self.sourceList selectedRowIndexes];
	//Set the label text to represent the new selection
	if([selectedIndexes count]==1) {
		[self.controlView setHidden:NO];
		[self.startMessage setHidden:YES];
	}
	else {
		[self.controlView setHidden:YES];
		[self.startMessage setHidden:NO];
	}
}

@end
