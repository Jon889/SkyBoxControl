//
//  UFCDObject.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFCDObject : NSObject
@property (nonatomic, strong) NSString *objectID;//called 'id' in spec however 'id' is reserved word in Objective-C
@property (nonatomic, strong) NSString *parentID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *creator; //NOT REQUIRED
@property (nonatomic, strong) NSArray *res;//NOT REQUIRED type:URI. NB: Can be mutpile value hence the NSArray
@property (nonatomic, strong) NSString *UPnPclass;//class in spec.
@property (nonatomic) BOOL restricted;
@property (nonatomic, strong) NSString *writeStatus; //NOT REQUIRED. values:WRITABLE, PROTECTED, NOT_WRITABLE, UNKNOWN, MIXED.
-(id)initWithXML:(id)xml;

@end

@interface UFCDObject (tempPrivate)
-(id)safeGetNodesForXPath:(NSString *)xpath fromXML:(NSXMLNode *)xml;
@end