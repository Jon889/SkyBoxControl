//
//  UFContainer.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 11/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFContainer : NSObject
@property (nonatomic, strong) NSString *containerID;
@property (nonatomic, strong) NSString *parentID;
@property (nonatomic) BOOL restricted;
@property (nonatomic, strong) NSString *title;
-(id)initWithXML:(id)xml;
@end
