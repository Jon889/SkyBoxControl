//
//  UFAction.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UFService;
@interface UFAction : NSObject
@property (nonatomic, weak) UFService *parentService;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *arguments;
-(id)initWithXML:(id)xml parentService:(UFService *)ps;
-(void)postWithArgumentDictionary:(NSDictionary *)dict completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) handler;
@end
