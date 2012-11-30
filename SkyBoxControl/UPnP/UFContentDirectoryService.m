//
//  UFContentDirectoryService.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 14/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFContentDirectoryService.h"
#import "GTMNSString+HTML.h"
#import "UFCDContainer.h"
#import "UFCDItem.h"
#import "UFCDVideoItem.h"
@implementation UFContentDirectoryService
-(void)fetchRootContainers:(void (^)(NSArray* subObjects, NSInteger numberReturned, NSInteger totalMatches, NSError* error)) handler {
	[self browseContainerWithID:@"0" startingIndex:0 completion:handler];
}
-(Class)classforUPnPObjectString:(NSString *)objclass {
	return @{@"object.item" : [UFCDItem class],
	@"object.container" : [UFCDContainer class],
	@"object.item.videoItem" : [UFCDVideoItem class]}[objclass];
}
-(void)browseContainerWithID:(NSString *)cID startingIndex:(NSInteger)si completion:(void (^)(NSArray* subObjects, NSInteger numberReturned, NSInteger totalMatches, NSError* error))handler {
	NSDictionary *arguments = @{ @"ObjectID" : cID,
	@"BrowseFlag" : @"BrowseDirectChildren",
	@"Filter" : @"*",
	@"StartingIndex" : [NSString stringWithFormat:@"%li",si],
	@"RequestedCount" : @"0",
	@"SortCriteria" : @"" };
	[[self actionForName:@"Browse"] postWithArgumentDictionary:arguments completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:[[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] gtm_stringByUnescapingFromHTML] options:0 error:nil];
		NSArray *containersRaw = [doc nodesForXPath:@"//Result/*[local-name() = 'DIDL-Lite']/*[local-name() = 'container']" error:nil];
		NSArray *itemsRaw = [doc nodesForXPath:@"//Result/*[local-name() = 'DIDL-Lite']/*[local-name() = 'item']" error:nil];
		NSArray *objectsRaw = [itemsRaw arrayByAddingObjectsFromArray:containersRaw];
		NSMutableArray *subObjects = [[NSMutableArray alloc] init];
		for (NSXMLNode *container in objectsRaw) {
			NSString *objclass = [[container nodesForXPath:@"./*[local-name() = 'class']" error:nil][0] stringValue];
			UFCDObject *cont = [[[self classforUPnPObjectString:objclass] alloc] initWithXML:container];
			[subObjects addObject:cont];
		}
		NSLog(@"%@", subObjects);
		
		NSInteger numberReturned = [[[doc nodesForXPath:@"//NumberReturned" error:nil][0] stringValue] integerValue];
		NSInteger totalMatches = [[[doc nodesForXPath:@"//TotalMatches" error:nil][0] stringValue] integerValue];
		
		handler(subObjects, numberReturned, totalMatches, nil);
	}];
}
-(void)browseContainer:(UFCDContainer *)container startingIndex:(NSInteger)si completion:(void (^)(NSArray* subObjects, NSInteger numberReturned, NSInteger totalMatches, NSError* error))handler {
	[self browseContainerWithID:[container objectID] startingIndex:(NSInteger)si completion:handler];
}
//-(UFContainer *)rootContainerForTitle:(NSString *)title {
//	NSArray *containersF = [self.actions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
//	return (containersF.count == 0) ? nil : containersF[0];
//}
@end
