//
//  SBCPlayService.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 10/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCPlayService.h"

@implementation SBCPlayService

-(void)play {
	[self playbackAtSpeed:1];
}
-(void)pause {
	[[self actionForName:@"Pause"] postWithArgumentDictionary:@{ @"InstanceID" : @"0" } completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
	}];
}
-(void)fastForward {
	[self getCurrentSpeed:^(NSInteger speed, NSError *error) {
		if (error) {
			
		} else {
			[self playbackAtSpeed:[self speedForCurrentSpeed:speed fastForward:YES]];
		}
	}];
}
-(void)rewind {
	[self getCurrentSpeed:^(NSInteger speed, NSError *error) {
		if (error) {
			
		} else {
			[self playbackAtSpeed:[self speedForCurrentSpeed:speed fastForward:NO]];
		}
	}];
}

-(void)playbackAtSpeed:(NSInteger)speed {
	[[self actionForName:@"Play"] postWithArgumentDictionary:@{@"InstanceID" : @"0", @"Speed" : [NSString stringWithFormat:@"%li", speed]} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSLog(@"%@ %@ %@", r, [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding], e);
	}];
}
-(void)getCurrentSpeed:(void (^)(NSInteger speed, NSError* error))callback {
	[[self actionForName:@"GetTransportInfo"] postWithArgumentDictionary:@{@"InstanceID" : @"0"} completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:d options:NSXMLNodeOptionsNone error:nil];
		NSError *err = nil;
		NSXMLNode *node = [doc nodesForXPath:@"//s:Envelope/s:Body/*[local-name() = 'GetTransportInfoResponse']/CurrentSpeed" error:&err][0];
		NSInteger currentSpeed = [[node stringValue] integerValue];
		callback(currentSpeed, e ?: err);
	}];
}
-(NSInteger)speedForCurrentSpeed:(NSInteger)cs fastForward:(BOOL)ff {
	int modifier = (ff) ? 1 : -1;
	if (30 == modifier * cs) {
		return cs;
	}
	if (cs == modifier * -30) {
		return modifier * -12;
	}
	if (cs == modifier * -12) {
		return modifier * -6;
	}
	if (cs == modifier * -6) {
		return modifier * -2;
	}
	if (cs == modifier * -2) {
		return modifier * 1;
	}
	if (cs == 1) {
		return modifier * 2;
	}
	if (cs == modifier * 2) {
		return modifier * 6;
	}
	if (cs == modifier * 6) {
		return modifier * 12;
	}
	if (cs == modifier * 12) {
		return modifier * 30;
	}
	return cs;
}
@end
