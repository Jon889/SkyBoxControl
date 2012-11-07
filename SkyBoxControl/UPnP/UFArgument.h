//
//  UFArgument.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NSString * UFArgumentDirection;
extern UFArgumentDirection const UFArgumentDirectionIn;
extern UFArgumentDirection const UFArgumentDirectionOut;

@interface UFArgument : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UFArgumentDirection direction;
@property (nonatomic) BOOL isReturnValue;
@property (nonatomic, strong) NSString *relatedStateVariableName;
-(id)initWithXML:(id)xml;
@end
