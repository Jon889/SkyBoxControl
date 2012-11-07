//
//  UFControlPoint.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 01/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFDevice.h"

@class UFControlPoint;
@protocol UFControlPointDelegate <NSObject>
-(void)controlPoint:(UFControlPoint *)controlPoint discoveredDevice:(UFDevice *)newDevice;//called when device is ready
@optional
-(void)controlPoint:(UFControlPoint *)controlPoint foundDevice:(UFDevice *)newDevice;//called as soon as device is found (before it is ready)
@end

@interface UFControlPoint : NSObject <UFDeviceDelegate>
@property (nonatomic, strong, readonly) NSArray *devices;
@property (nonatomic, weak) id<UFControlPointDelegate> delegate;
-(BOOL)startSearching;
-(void)stopSearching;
@end
