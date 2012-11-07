//
//  UFService.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFService.h"
#import "UFAction.h"
#import "UFDevice.h"

@implementation UFService
-(id)initWithXML:(id)xml parentDevice:(UFDevice *)pd {
	if (self = [super init]) {
		[self setParentDevice:pd];
		[self setActions:[[NSMutableArray alloc] init]];
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
	[self setServiceType:[[self safeGetNodesForXPath:@"./serviceType" fromXML:xml][0] stringValue]];
	[self setServiceId:[[self safeGetNodesForXPath:@"./serviceId" fromXML:xml][0] stringValue]];
	[self setSCPDURL:[[self safeGetNodesForXPath:@"./SCPDURL" fromXML:xml][0] stringValue]];
	[self setControlURL:[[self safeGetNodesForXPath:@"./controlURL" fromXML:xml][0] stringValue]];
	[self setEventSubURL:[[self safeGetNodesForXPath:@"./eventSubURL" fromXML:xml][0] stringValue]];
	
//	if (![[NSURL URLWithString:self.SCPDURL] host]) {
		NSURL *u = [NSURL URLWithString:self.SCPDURL relativeToURL:[NSURL URLWithString:self.parentDevice.baseURL]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:u];
	[request addValue:@"SKY_skyplus" forHTTPHeaderField:@"User-Agent"];
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:NSXMLNodeOptionsNone error:nil];
			NSArray *actions = [self safeGetNodesForXPath:@"//actionList/action" fromXML:doc];
			for (id actionxml in actions) {
				UFAction *action = [[UFAction alloc] initWithXML:actionxml parentService:self];
				[(NSMutableArray *)self.actions addObject:action];
			}

			
		}];
		
//	}
}

-(UFAction *)actionForName:(NSString *)name {
	NSArray *actionsF = [self.actions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
	return (actionsF.count == 0) ? nil : actionsF[0];
}
@end
