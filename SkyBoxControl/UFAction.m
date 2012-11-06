//
//  UFAction.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFAction.h"
#import "UFArgument.h"
#import "UFService.h"
#import "UFDevice.h"

@implementation UFAction
-(id)initWithXML:(id)xml parentService:(UFService *)ps {
	if (self = [super init]) {
		[self setParentService:ps];
		[self setArguments:[[NSMutableArray alloc] init]];
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
	NSArray *arguments = [self safeGetNodesForXPath:@"./argumentList/argument" fromXML:xml];
	for (id argumentxml in arguments) {
		UFArgument *arg = [[UFArgument alloc] initWithXML:argumentxml];
		[(NSMutableArray *)self.arguments addObject:arg];
	}
}
-(NSString *)description {
	return [[super description] stringByAppendingString:self.name];
}

-(NSString *)argumentStringFromDictionary:(NSDictionary *)dict {
	NSMutableString *collector = [NSMutableString string];
	for (NSString *key in [dict allKeys]) {
		NSString *value = dict[key];
		if ([self isValue:value validForArgument:key]) {
			[collector appendString:[[NSXMLElement elementWithName:key stringValue:value] XMLString]];
		} else {
			NSLog(@"Invalid value(%@) for argument(%@)", value, key);
		}
	}
	//has all required arguments?
	return collector;
}
-(BOOL)isValue:(NSString *)value validForArgument:(NSString *)argumentName {
	UFArgument *argument = [self argumentForName:argumentName];
	if (!argument) {
		return NO;
	}
	/*if (![argument isValueAllowed:value]) {
		return NO;
	}*/
	return YES;
}
-(void)postWithArgumentDictionary:(NSDictionary *)dict completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) handler {/*
	POST path of control URL HTTP/1.1
HOST: host of control URL:port of control URL
	CONTENT-LENGTH: bytes in body
	CONTENT-TYPE: text/xml; charset="utf-8"
SOAPACTION: "urn:schemas-upnp-org:service:serviceType:v#actionName"
	<?xml version="1.0"?>
	<s:Envelope
xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"> <s:Body>
	<u:actionName xmlns:u="urn:schemas-upnp-org:service:serviceType:v"> <argumentName>in arg value</argumentName>
	other in args and their values go here, if any
		</u:actionName> </s:Body>
		</s:Envelope>*/
	NSURL *url;
	NSURL *baseURL = [NSURL URLWithString:self.parentService.parentDevice.baseURL];
	NSURL *controlURL = [NSURL URLWithString:self.parentService.controlURL];
	if ([controlURL host]) {
		url = controlURL;
	} else {
		url = [NSURL URLWithString:self.parentService.controlURL relativeToURL:baseURL];
	}
	NSString *SOAPAction = [NSString stringWithFormat:@"%@#%@", self.parentService.serviceType, self.name];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"SKY_skyplus" forHTTPHeaderField:@"User-Agent"];
	[request addValue:@"text/xml; charset=\"utf-8\"" forHTTPHeaderField:@"Content-Type"];
	[request addValue:[NSString stringWithFormat:@"\"%@\"", SOAPAction] forHTTPHeaderField:@"SOAPACTION"];
	[request setHTTPMethod:@"POST"];
	NSString *arguments = [self argumentStringFromDictionary:dict];
	NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><u:%@ xmlns:u=\"%@\">%@</u:%@></s:Body></s:Envelope>\n\n", self.name, self.parentService.serviceType, arguments ,self.name];
//	NSString *body = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><u:Pause xmlns:u=\"urn:schemas-nds-com:service:SkyPlay:2\"><InstanceID>0</InstanceID></u:Pause></s:Body></s:Envelope>\n\n";
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
}
-(UFArgument *)argumentForName:(NSString *)name {
	NSArray *argumentsF = [self.arguments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
	return (argumentsF.count == 0) ? nil : argumentsF[0];
}

@end
