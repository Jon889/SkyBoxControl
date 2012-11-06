//
//  SBCDiscoverer.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//
/*
 
M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:1900
MAN: "ssdp:discover"
MX: 3
ST: ssdp:rootdevice
 */

#import "SBCDiscoverer.h"
#import "GCDAsyncUdpSocket.h"

@interface SBCDiscoverer () <GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) NSMutableArray *discoveredServices;
@end
@implementation SBCDiscoverer
-(id)init {
	if (self = [super init]) {
		[self setDiscoveredServices:[NSMutableArray array]];
	}
	return self;
}
-(BOOL)startDiscovery {
	GCDAsyncUdpSocket *broadcast = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
	NSError *startError = nil;
	[broadcast bindToPort:0 error:&startError];
	if (startError) {
		return NO;
	}
	[broadcast beginReceiving:&startError];
	if (startError) {
		return NO;
	}
	[broadcast enableBroadcast:YES error:&startError];
	if (startError) {
		return NO;
	}
	NSLog(@"Socket inited");
	NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: ssdp:rootdevice\r\nUSER-AGENT: iOS UPnP/1.1 TestApp/1.0\r\n\r\n";
	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
	[[self discoveredServices] removeAllObjects];
	[broadcast sendData:data toHost:@"239.255.255.250" port:1900 withTimeout:-1 tag:0];
	return YES;
	
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (data)
    {
		SBCResponse *resp = [[SBCResponse alloc] initWithData:data];
		if ([resp[@"SERVER"] containsString:@"SKY"]) {
			[self.discoveredServices addObject:resp];
			if (self.delegate && [self.delegate conformsToProtocol:@protocol(SBCDiscovererDelegate)]) {
				[self.delegate performSelector:@selector(discoverer:discoveredService:) withObject:self withObject:resp];
			}
		}
	}
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"DIDNT ESEND");
}
-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
	NSLog(@"ERRO");
}
@end

