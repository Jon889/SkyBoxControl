//
//  UFResponse.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFResponse : NSObject
@property (nonatomic, strong) NSString  *rawResponse;
@property (nonatomic, strong) NSString  *httpVersion;
@property (nonatomic)		  NSUInteger responseCode;
@property (nonatomic, strong) NSString  *responseString;
@property (nonatomic, strong) NSDictionary *headerFields;
@property (nonatomic, strong) NSString *body;
-(id)initWithData:(NSData *)data;
-(id)initWithString:(NSString *)string;
-(id)objectForKeyedSubscript:(id)key;
-(BOOL)isSameHostToResponse:(UFResponse *)otherResponse;
@end
