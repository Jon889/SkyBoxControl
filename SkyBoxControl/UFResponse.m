//
//  UFResponse.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFResponse.h"

//HTTP/1.1 200 OK
//CACHE-CONTROL: max-age=115
//DATE: Mon, 05 Jan 1970 14:17:14 GMT
//EXT:
//LOCATION: http://192.168.2.21:49153/description4.xml
//OPT: "http://schemas.upnp.org/upnp/1/0/"; ns=01
//01-NLS: 49e0b600-1dd2-11b2-8349-ad5f5f6557ee
//SERVER: Linux/2.6.18.8 UPnP/1.0 SKY DLNADOC/1.50
//X-User-Agent: redsonic
//ST: upnp:rootdevice
//USN: uuid:444D5376-3253-6B79-5365-0019fb02711e::upnp:rootdevice


@implementation UFResponse
-(id)initWithData:(NSData *)data {
	return [self initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}
-(id)initWithString:(NSString *)string {
	if (self = [super init]) {
		NSRange bodyStart = [string rangeOfString:@"\n\n"];
		if (bodyStart.location == NSNotFound) {
			bodyStart = NSMakeRange(string.length, 0);
		}
		NSString *head = [string substringToIndex:bodyStart.location];
		[self setBody:[string substringFromIndex:bodyStart.location + bodyStart.length]];
		NSMutableArray *headLines = [[head componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
		[headLines removeObject:@""];
		NSArray *httpComponents = [headLines[0] componentsSeparatedByString:@" "];
		[self setHttpVersion:httpComponents[0]];
		[self setResponseCode:[httpComponents[1] intValue]];
		[self setResponseString:httpComponents[2]];
		[headLines removeObjectAtIndex:0];
		NSMutableDictionary *headers = [NSMutableDictionary dictionary];
		for (NSString *line in headLines) {
			NSRange colonRange = [line rangeOfString:@":"];
			NSString *key = [[[line substringToIndex:colonRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
			NSString *value = [[line substringFromIndex:colonRange.location + colonRange.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			headers[key] = value;
		}
		[self setHeaderFields:[headers copy]];
	}
	return self;
}
-(id)objectForKeyedSubscript:(id)key {
	return [self headerFields][key];
}
-(NSString *)description {
	return [NSString stringWithFormat:@"HTTP version: %@ \nResponse Status: %li - %@ \nHeader Fields: %@ \nBody:%@", self.httpVersion, self.responseCode, self.responseString, self.headerFields, self.body];
}
-(BOOL)isSameHostToResponse:(UFResponse *)otherResponse {
	NSString *myHost = [(NSURL*)[NSURL URLWithString:self[@"LOCATION"]] host];
	NSString *otherHost = [(NSURL*)[NSURL URLWithString:otherResponse[@"LOCATION"]] host];
	return [myHost isEqualToString:otherHost];
}
@end
