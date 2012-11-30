//
//  UFCDContainer.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDObject.h"

@interface UFCDContainer : UFCDObject
@property (nonatomic)		  NSInteger childCount; //NOT REQUIRED
@property (nonatomic, strong) NSString *createClass; //NOT REQUIRED
@property (nonatomic, strong) NSString *searchClass; //NOT REQUIRED
@property (nonatomic)		  BOOL searchable; //NOT REQUIRED
@end
