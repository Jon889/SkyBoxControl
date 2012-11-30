//
//  UFDevice.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFDevice.h"
#import "UFService.h"

@interface UFDevice () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSXMLDocument *descriptionDocument;
@end
@implementation UFDevice
-(id)initWithResponseData:(NSData *)data {
	return  [self initWithResponseString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}
-(id)initWithResponseString:(NSString *)string {
	if (self = [super init]) {
		self.isReady = NO;
		self.response = [[UFResponse alloc] initWithString:string];
		self.services = [[NSMutableArray alloc] init];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.response[@"LOCATION"]]];
		[request addValue:@"SKY_skyplus" forHTTPHeaderField:@"User-Agent"];

		NSLog(@"LOADING URL: %@", request.URL);
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			NSError *xmlError = nil;
			if (data) {
				self.descriptionDocument = [[NSXMLDocument alloc] initWithData:data options:NSXMLNodeOptionsNone error:&xmlError];
			}
			if (xmlError || !data || error) {
				NSLog(@"Error: XML: %@ \n Connection: %@", xmlError, error);
				self.isReady = NO;
				[self.delegate performSelector:@selector(device:failedToBecomeReadyWithError:) withObject:self withObject:xmlError ?: error];
			} else {
				[self parseDescriptionDocument];
			}
		}];
	}
	return self;
}
/*
	<device>
		<deviceType>urn:schemas-nds-com:device:SkyServe:2</deviceType>
		<friendlyName>330102494</friendlyName>
		<manufacturer>Amstrad</manufacturer>
		<modelDescription>4F3001</modelDescription>
		<modelName>Sky+HD</modelName>
		<modelNumber>R005.054.01.00P (0gmdsmy)</modelNumber>
		<UDN>uuid:444D5376-3253-6B79-5365-0019fb02711e</UDN>
		<serviceList>
			<service>
				<serviceType>urn:schemas-nds-com:service:SkyBook:2</serviceType><serviceId>urn:nds-com:serviceId:SkyBook2</serviceId><SCPDURL>/scm_srs.xml</SCPDURL><controlURL>/SkyBook2</controlURL><eventSubURL>/SkyBook2</eventSubURL></service><service><serviceType>urn:schemas-nds-com:service:SkyBrowse:2</serviceType><serviceId>urn:nds-com:serviceId:SkyBrowse2</serviceId><SCPDURL>/scm_cds.xml</SCPDURL><controlURL>/SkyBrowse2</controlURL><eventSubURL>/SkyBrowse2</eventSubURL></service>
 </serviceList></device>
 */
-(id)safeGetNodesForXPath:(NSString *)xpath {
	NSError *err = nil;
	NSArray *nodes = [self.descriptionDocument nodesForXPath:xpath error:&err];
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
-(Class)classForServiceType:(NSString *)serviceType {
	if ([self.delegate conformsToProtocol:@protocol(UFDeviceDelegate)]) {
		Class mappedClass = [self.delegate serviceClassMap][serviceType];
		if (mappedClass && [mappedClass isSubclassOfClass:[UFService class]]) {
			return mappedClass;
		}
	}
	return [UFService class];
}
-(void)parseDescriptionDocument {
	[self setDeviceType:[[self safeGetNodesForXPath:@"//device/deviceType"][0] stringValue]];
	[self setFriendlyName:[[self safeGetNodesForXPath:@"//device/friendlyName"][0] stringValue]];
	[self setManufacturer:[[self safeGetNodesForXPath:@"//device/manufacturer"][0] stringValue]];
	[self setModelDescription:[[self safeGetNodesForXPath:@"//device/modelDescription"][0] stringValue]];
	[self setModelName:[[self safeGetNodesForXPath:@"//device/modelName"][0] stringValue]];
	[self setModelNumber:[[self safeGetNodesForXPath:@"//device/modelNumber"][0] stringValue]];
	[self setUDN:[[self safeGetNodesForXPath:@"//device/UDN"][0] stringValue]];
	[self setBaseURL:[[self safeGetNodesForXPath:@"//URLBase"][0] stringValue]];
	NSArray *services = [self safeGetNodesForXPath:@"//device/serviceList/service"];
	for (id service in services) {
		NSString *serviceType = [[service nodesForXPath:@"./serviceType" error:nil][0] stringValue];
		UFService *newservice = [[[self classForServiceType:serviceType] alloc] initWithXML:service parentDevice:self];
		[(NSMutableArray *)self.services addObject:newservice];
	}
	
}
-(UFService *)serviceForId:(NSString *)serviceId {
	NSArray *services = [self.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serviceId == %@", serviceId]];
	return (services.count == 0) ? nil : services[0];
}
-(UFService *)serviceForType:(NSString *)serviceType {
	NSArray *services = [self.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serviceType == %@", serviceType]][0];
	return (services.count == 0) ? nil : services[0];
}
-(void)serviceIsReady:(UFService *)service {
	for (UFService *service in self.services) {
		if (![service isReady]) {
			return;
		}
	}
	self.isReady = YES;
	[self.delegate performSelector:@selector(deviceIsNowReady:) withObject:self];
}



@end
