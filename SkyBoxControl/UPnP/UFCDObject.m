//
//  UFCDObject.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDObject.h"

@implementation UFCDObject
-(id)initWithXML:(id)xml {
	if (self = [super init]) {
		[self setObjectID:[[xml attributeForName:@"id"] stringValue]];
		[self setParentID:[[xml attributeForName:@"parentID"] stringValue]];
		[self setRestricted:[[[xml attributeForName:@"restricted"] stringValue] boolValue]];
		
		[self setTitle:[[self safeGetNodesForXPath:@"./*[local-name() = 'title']" fromXML:xml][0] stringValue]];
		[self setCreator:[[self safeGetNodesForXPath:@"./*[local-name() = 'creator']" fromXML:xml][0] stringValue]];
		
		[self setRes:[self safeGetNodesForXPath:@"./*[local-name() = 'res']" fromXML:xml]];
		[self setUPnPclass:[[self safeGetNodesForXPath:@"./*[local-name() = 'class']" fromXML:xml][0] stringValue]];
		
		[self setWriteStatus:[[self safeGetNodesForXPath:@"./*[local-name() = 'writeStatus']" fromXML:xml][0] stringValue]];
	}
	return self;
}
-(id)safeGetNodesForXPath:(NSString *)xpath fromXML:(NSXMLNode *)xml {
	NSError *err = nil;
	NSArray *nodes = [xml nodesForXPath:xpath error:&err];
	if (err) {
		NSLog(@"Error finding nodes for XPath(%@): %@", xpath, err);
	}
	if (nodes && [nodes count] >= 1) {
		return nodes;
	} else {
		NSLog(@"No nodes found for XPath: %@", xpath);
	}
	return nil;
}

@end
