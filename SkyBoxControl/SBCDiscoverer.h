//
//  SBCDiscoverer.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFResponse.h"
typedef UFResponse SBCResponse;
@class SBCDiscoverer;
@protocol SBCDiscovererDelegate <NSObject>
-(void)discoverer:(SBCDiscoverer *)discoverer discoveredService:(SBCResponse *)service;
@end
@interface SBCDiscoverer : NSObject
@property (nonatomic, weak) id<SBCDiscovererDelegate> delegate;
-(BOOL)startDiscovery;
@end
