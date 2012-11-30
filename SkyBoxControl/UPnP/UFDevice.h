//
//  UFDevice.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFResponse.h"
#import "UFService.h"
@class UFDevice;
@protocol UFDeviceDelegate <NSObject>
-(void)deviceIsNowReady:(UFDevice *)device;
-(NSDictionary *)serviceClassMap;
@optional
-(void)device:(UFDevice *)device failedToBecomeReadyWithError:(NSError *)error;
@end
@interface UFDevice : NSObject
@property (nonatomic, strong) UFResponse *response;
@property (nonatomic) BOOL isReady;

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *friendlyName;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *manufacturerURL;
@property (nonatomic, strong) NSString *modelDescription;
@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSString *modelNumber;
@property (nonatomic, strong) NSString *modelURL;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *UDN;
@property (nonatomic, strong) NSString *UPC;

@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSArray *embeddedDevices;
@property (nonatomic, strong) NSURL *presentationURL;
@property (nonatomic, weak) id<UFDeviceDelegate> delegate;
-(id)initWithResponseData:(NSData *)data;
-(id)initWithResponseString:(NSString *)string;
-(UFService *)serviceForId:(NSString *)serviceId;
-(UFService *)serviceForType:(NSString *)serviceType;
//delegate from service
-(void)serviceIsReady:(UFService *)service;
@end
