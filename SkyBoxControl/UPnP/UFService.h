//
//  UFService.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFAction.h"
@class UFDevice;
@interface UFService : NSObject
@property (nonatomic, weak) UFDevice *parentDevice;
@property (nonatomic, strong) NSString *serviceType;
@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *SCPDURL;
@property (nonatomic, strong) NSString *controlURL;
@property (nonatomic, strong) NSString *eventSubURL;

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSArray *stateVariables;
@property (nonatomic) BOOL isReady;
-(id)initWithXML:(id)xml parentDevice:(UFDevice *)pd;
-(UFAction *)actionForName:(NSString *)name;
-(void)subscribeToEvents;
@end
