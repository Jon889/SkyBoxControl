//
//  SBCDevice.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCPlayService.h"

@class UFService, UFContentDirectoryService;
@interface SBCAggregateSkyBox : NSObject
@property (nonatomic, strong) NSMutableArray *devices;
-(UFService *)serviceForType:(NSString *)serviceType;
-(UFService *)serviceForId:(NSString *)serviceId;
-(SBCPlayService *)skyPlayService; //remote control (playback, channel)
-(UFContentDirectoryService *)skyBrowseService; //planner
-(UFService *)skyBookService; //set/unset recordings
-(BOOL)isReady;
@end

