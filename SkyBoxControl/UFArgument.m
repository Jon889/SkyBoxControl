//
//  UFArgument.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFArgument.h"
UFArgumentDirection const UFArgumentDirectionIn = @"in";
UFArgumentDirection const UFArgumentDirectionOut = @"out";
@implementation UFArgument
-(id)initWithXML:(id)xml {
	if (self = [super init]) {
		[self parseXML:xml];
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

-(void)parseXML:(NSXMLElement *)xml {
	[self setName:[[self safeGetNodesForXPath:@"./name" fromXML:xml][0] stringValue]];
	[self setDirection:[[self safeGetNodesForXPath:@"./direction" fromXML:xml][0] stringValue]];
	[self setRelatedStateVariableName:[[self safeGetNodesForXPath:@"./relatedStateVariable" fromXML:xml][0] stringValue]];
	[self setIsReturnValue:([self safeGetNodesForXPath:@"./retval" fromXML:xml] == nil) ? NO : YES];
}

-(NSString *)description {
	return [[super description] stringByAppendingFormat:@"%@ (%@)", self.name, self.direction];
}

@end
