//
//  UFCDitem.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDObject.h"

@interface UFCDItem : UFCDObject
@property (nonatomic, strong) NSString *refID; //NOT REQUIRED
-(id)valueFromBackingXMLForKey:(NSString *)key;
@end
@interface UFCDItem ()
@property (nonatomic, strong) NSXMLElement *backingXML;
@end