//
//  UFCDContainer.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDContainer.h"

@implementation UFCDContainer
-(id)initWithXML:(id)xml {
	if (self = [super initWithXML:xml]) {
		[self setChildCount:[[[xml attributeForName:@"childCount"] stringValue] integerValue]];
		[self setSearchable:[[[xml attributeForName:@"searchable"] stringValue] boolValue]];
		
		[self setCreateClass:[[self safeGetNodesForXPath:@"./*[local-name() = 'createClass']" fromXML:xml][0] stringValue]];
		[self setSearchClass:[[self safeGetNodesForXPath:@"./*[local-name() = 'searchClass']" fromXML:xml][0] stringValue]];
	}
	return self;
}
@end
