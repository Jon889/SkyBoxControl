//
//  SBCDevice.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UFService;
@interface SBCAggregateSkyBox : NSObject
@property (nonatomic, strong) NSMutableArray *devices;
-(UFService *)serviceForType:(NSString *)serviceType;
-(UFService *)serviceForId:(NSString *)serviceId;
-(UFService *)skyPlayService;
@end
