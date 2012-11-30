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
@interface UFService ()
@property (nonatomic, strong) NSString *SID;
@property (nonatomic) NSInteger subscribeTimeout;
@end
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

			[self hasLoadedActions];
		}];
		
//	}
}
-(void)hasLoadedActions {
	self.isReady = YES;
	[self.parentDevice serviceIsReady:self];
}

-(UFAction *)actionForName:(NSString *)name {
	NSArray *actionsF = [self.actions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
	return (actionsF.count == 0) ? nil : actionsF[0];
}
-(NSString *)description {
	return [[super description] stringByAppendingString:self.serviceId];
}
-(void)subscribeToEvents {
	NSURL *url;
	NSURL *baseURL = [NSURL URLWithString:self.parentDevice.baseURL];
	NSURL *controlURL = [NSURL URLWithString:self.eventSubURL];
	if ([controlURL host]) {
		url = controlURL;
	} else {
		url = [NSURL URLWithString:self.controlURL relativeToURL:baseURL];
	}

	NSArray *addresses = [[NSHost currentHost] addresses];
	NSString *ipv4Address = nil;
	for (NSString *address in addresses) {
		if (![address hasPrefix:@"127"] && [address rangeOfString:@":"].location == NSNotFound) {
			ipv4Address = address;
			break;
		}
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"<http://google.com/>" forHTTPHeaderField:@"CALLBACK"];
	[request addValue:@"upnp:event" forHTTPHeaderField:@"NT"];
	[request addValue:@"Second-300" forHTTPHeaderField:@"TIMEOUT"];
	[request setHTTPMethod:@"SUBSCRIBE"];
	
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSHTTPURLResponse *resp = r;
		NSInteger statusCode = [resp statusCode];
		if (statusCode == 400) {
			NSLog(@"Requst can't send SID as well as NT/Callback");
		} else if (statusCode == 412) {
			NSLog(@"Callback missing or invalid, or NT != upnp:event");
		} else if (statusCode >= 500 && statusCode < 600) {
			NSLog(@"Published unable to accept subscription (eg: due to insufficient resources)");
		} else {
			NSString *rSID = [resp allHeaderFields][@"SID"];
			NSString *rtimeout = [resp allHeaderFields][@"TIMEOUT"];
			if ([rSID isNotEmpty]) {
				self.SID = rSID;
			}
		}
	}];
}
@end
