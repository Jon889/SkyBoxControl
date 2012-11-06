//
//  UFControlPoint.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 01/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFControlPoint.h"
#import "GCDAsyncUdpSocket.h" 

@interface UFControlPoint () {
	NSMutableArray *_devices;
	GCDAsyncUdpSocket *_broadcast;
}
@end

@implementation UFControlPoint

-(id)init {
	if (self = [super init]) {
		_devices = [[NSMutableArray alloc] init];
	}
	return self;
}

-(BOOL)startSearching {
	return [self startSearchingWithST:@"ssdp:rootdevice"];
}

-(BOOL)startSearchingWithST:(NSString *)st {
	_broadcast = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
	NSError *startError = nil;
	[_broadcast bindToPort:0 error:&startError];
	if (startError) {
		return NO;
	}
	[_broadcast beginReceiving:&startError];
	if (startError) {
		return NO;
	}
	[_broadcast enableBroadcast:YES error:&startError];
	if (startError) {
		return NO;
	}
	NSLog(@"Socket inited");
	NSString *str = [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\nHOST: 239.255.255.250:1900\nMAN: \"ssdp:discover\"\nMX: 3\nST: %@\n\n", st];
	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
	[_devices removeAllObjects];
	[_broadcast sendData:data toHost:@"239.255.255.250" port:1900 withTimeout:-1 tag:0];
	return YES;
	
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (data) {
		UFDevice *device = [[UFDevice alloc] initWithResponseData:data];
		[device setDelegate:self];
		[_devices addObject:device];
		if (self.delegate && [self.delegate respondsToSelector:@selector(controlPoint:foundDevice:)]) {
			[self.delegate performSelector:@selector(controlPoint:foundDevice:) withObject:self withObject:device];
		}
	}
	
}
-(void)deviceIsNowReady:(UFDevice *)device {
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(UFControlPointDelegate)]) {
		[self.delegate performSelector:@selector(controlPoint:discoveredDevice:) withObject:self withObject:device];
	}
}
-(void)stopSearching {
	[_broadcast close];
}
@end
