//
//  UFCDVideoItem.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDVideoItem.h"
#import "NSString+JP.h"

@implementation UFCDVideoItem
-(id)initWithXML:(id)xml {
	if (self = [super initWithXML:xml]) {
	
		[self setGenres:[self stringValueArrayFromNodes:[self safeGetNodesForXPath:@"./*[local-name() = 'genres']" fromXML:xml]]];

		[self setLongDescription:[[self safeGetNodesForXPath:@"./*[local-name() = 'longDescription']" fromXML:xml][0] stringValue]];
		
		[self setProducers:[self stringValueArrayFromNodes:[self safeGetNodesForXPath:@"./*[local-name() = 'producers']" fromXML:xml]]];
		
		[self setRating:[[self safeGetNodesForXPath:@"./*[local-name() = 'rating']" fromXML:xml][0] stringValue]];
		
		//actors
		//directors
		
		[self setItemDescription:[[self safeGetNodesForXPath:@"./*[local-name() = 'description']" fromXML:xml][0] stringValue]];
		
		[self setPublishers:[self stringValueArrayFromNodes:[self safeGetNodesForXPath:@"./*[local-name() = 'publisher']" fromXML:xml]]];
		
		[self setLanguage:[[self safeGetNodesForXPath:@"./*[local-name() = 'language']" fromXML:xml][0] stringValue]];
		
		[self setRelations:[self stringValueArrayFromNodes:[self safeGetNodesForXPath:@"./*[local-name() = 'relation']" fromXML:xml]]];
	}
	return self;
}
-(NSArray *)stringValueArrayFromNodes:(NSArray *)nodes {
	NSMutableArray *collector = [NSMutableArray array];
	for (NSXMLNode *node in nodes) {
		NSString *string = [node stringValue];
		if ([string isNotEmpty]) {
			[collector addObject:string];
		}
	}
	return [collector copy];
}
-(NSString *)description {
	return [[super description] stringByAppendingString:self.title];
}
@end
