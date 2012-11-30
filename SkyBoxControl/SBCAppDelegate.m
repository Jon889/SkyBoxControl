//
//  SBCAppDelegate.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCAppDelegate.h"
#import "SBCAggregateSkyBox.h"
#import "PXSourceList.h"
#import "UFControlPoint.h"
#import "UFDevice.h"
#import "SBCPlayService.h"
#import "GTMNSString+HTML.h"
#import "UFContainer.h"
#import "UFContentDirectoryService.h"
#import "PXListViewDelegate.h"
#import "PXListView.h"
#import "MyListViewCell.h"
#import "SBCPlannerModel.h"
#import "SBCPlannerCollection.h"
#import "UFCDVideoItem.h"
#import "SBCControlView.h"

@interface SBCAppDelegate () <UFControlPointDelegate, PXSourceListDataSource, PXSourceListDelegate, PXListViewDelegate, NSSpeechRecognizerDelegate, SBCControlViewDelegate>{
	UFControlPoint *cp;
}
@property (nonatomic, strong) NSMutableArray *filteredDevices;
@property (nonatomic, strong) SBCPlannerModel *plannerModel;
@end
@implementation SBCAppDelegate

-(SBCPlannerModel *)plannerModel {
	if (!_plannerModel) {
		_plannerModel = [[SBCPlannerModel alloc] init];
	}
	return _plannerModel;
}


- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)command {
	if ([command isEqualToString:@"Play"]) {
		[[[self selectedBox] skyPlayService] play];
	} else if ([command isEqualToString:@"Pause"]) {
		[[[self selectedBox] skyPlayService] pause];
	} else if ([command isEqualToString:@"Forward"]) {
		[[[self selectedBox] skyPlayService] fastForward];
	} else if ([command isEqualToString:@"Rewind"]) {
		[[[self selectedBox] skyPlayService] rewind];
	}
}
-(SBCAggregateSkyBox *)selectedBox {
	return [self.filteredDevices objectAtIndex:0];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.filteredDevices = [NSMutableArray array];
	
	cp = [[UFControlPoint alloc] init];
	[cp setServiceClassMap:@{ @"urn:schemas-nds-com:service:SkyPlay:2" : [SBCPlayService class],
	 @"urn:schemas-nds-com:service:SkyBrowse:2" : [UFContentDirectoryService class]}];
	[cp setDelegate:self];
	[cp startSearching];
	
	NSSpeechRecognizer *sr = [[NSSpeechRecognizer alloc] init];
	[sr setCommands:@[@"Play", @"Pause", @"Forward", @"Rewind"]];
	[sr setDelegate:self];
	[sr startListening];
	
}
-(void)controlPoint:(UFControlPoint *)controlPoint discoveredDevice:(UFDevice *)newDevice {
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
	if ([self.filteredDevices count] == 1 && [[self.filteredDevices objectAtIndex:0] isReady]) {
		[self syncPlanner];
		[self.controlView setHidden:NO];
	}
}
-(void)syncPlanner {
	SBCAggregateSkyBox *skyBox = [self selectedBox];
	[self.progressBar setHidden:NO];
	[[skyBox skyBrowseService] fetchRootContainers:^(NSArray* containers, NSInteger numberReturned, NSInteger totalMatches, NSError* error) {
		UFContainer *pvrContainer = [containers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title == 'pvr'"]][0];
		NSMutableArray *collector = [NSMutableArray array];
		__block NSInteger ktotalMatches;
		__block id handler = ^(NSArray* sc, NSInteger numberReturned, NSInteger totalMatches, NSError* error) {
			ktotalMatches = totalMatches;
			[collector addObjectsFromArray:sc];
			[self.progressBar setDoubleValue:(double)collector.count/(double)totalMatches];
			if (collector.count < totalMatches) {
				[[skyBox skyBrowseService] browseContainer:pvrContainer startingIndex:collector.count completion:handler];
			} else {
				[self.plannerModel setBaseItems:[collector filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"X_recStatus = '5' AND X_bookingDiskQuotaName = 'user'"]]];
				[self.plannerModel groupByKey:@"title"];
				[self.listView reloadData];
				[self.progressBar setHidden:YES];
			}
		};
		[[skyBox skyBrowseService] browseContainer:pvrContainer startingIndex:0 completion:handler];
	}];
	[[skyBox skyBrowseService] subscribeToEvents];
	
}



- (NSUInteger)numberOfRowsInListView:(PXListView*)aListView {
	return [self.plannerModel numberOfItems];
}
- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row {
	return 57;
}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row {
	MyListViewCell *cell = (MyListViewCell *)[aListView dequeueCellWithReusableIdentifier:@"cell"];
	if (!cell) {
		cell = [MyListViewCell cellLoadedFromNibNamed:@"MyListViewCell" reusableIdentifier:@"cell"];
	}
	SBCPlannerCollection *currentCollection = [self.plannerModel objectAtIndex:row];
	
	[cell.titleLabel setStringValue:[[self.plannerModel objectAtIndex:row] title]];
	BOOL hasOneItem = [currentCollection numberOfItems] == 1;
	if (hasOneItem) {
		UFCDVideoItem *item = [currentCollection objectAtIndex:0];
		BOOL isViewed = [[item valueFromBackingXMLForKey:@"X_isViewed"] boolValue];
		[cell.detailLabel setStringValue:(isViewed) ? @"Viewed" : @"Recorded"];
		[cell.descriptionLabel setStringValue:[item itemDescription]];
	} else {
		[cell.detailLabel setStringValue:[NSString stringWithFormat:@"%li episodes", [[self.plannerModel objectAtIndex:row] numberOfItems]]];
	}
	return cell;
}
-(void)listView:(PXListView *)aListView rowDoubleClicked:(NSUInteger)rowIndex {
	SBCPlannerCollection *currentCollection = [self.plannerModel objectAtIndex:rowIndex];
	NSString *pid = [[(id)[currentCollection objectAtIndex:0] valueForKey:@"res"][0] stringValue];
	SBCAggregateSkyBox *skyBox = [self selectedBox];
	UFAction *ac = [[skyBox skyPlayService] actionForName:@"SetAVTransportURI"];
	[ac postWithArgumentDictionary:@{ @"InstanceID" : @"0", @"CurrentURI" : [NSString stringWithFormat:@"%@?position=1&speed=1",pid] ,@"CurrentURIMetaData": @"NOT_IMPLEMENTED"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSLog(@"DONE");
	}];
}

-(void)controlView:(SBCControlView *)cview changedSpeedValue:(NSString *)sv {
	if ([sv isEqualToString:@"0"]) {
		[[[self selectedBox] skyPlayService] pause];
	} else {
		[[[self selectedBox] skyPlayService] playbackAtSpeed:[sv integerValue]];
	}
}
@end
