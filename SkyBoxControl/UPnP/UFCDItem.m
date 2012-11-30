//
//  UFCDitem.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDItem.h"

@implementation UFCDItem
-(id)initWithXML:(id)xml {
	if (self = [super initWithXML:xml]) {
		self.backingXML = xml;
		[self setRefID:[[xml attributeForName:@"refID"] stringValue]];
	}
	return self;
}
-(id)valueForUndefinedKey:(NSString *)key {
	return [self valueFromBackingXMLForKey:key] ?: [super valueForUndefinedKey:key];
}

-(id)valueFromBackingXMLForKey:(NSString *)key {
	return [[self safeGetNodesForXPath:[NSString stringWithFormat:@"./*[local-name() = '%@']", key] fromXML:self.backingXML][0] stringValue];
}
@end
