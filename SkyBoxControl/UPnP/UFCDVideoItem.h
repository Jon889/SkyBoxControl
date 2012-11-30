//
//  UFCDVideoItem.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 15/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFCDItem.h"

@interface UFCDVideoItem : UFCDItem
@property (nonatomic, strong) NSArray *genres; //Type:string NOT REQUIRED
@property (nonatomic, strong) NSString *longDescription; //NOT REQUIRED
@property (nonatomic, strong) NSArray *producers; //Type:string NOT REQUIRED
@property (nonatomic, strong) NSString *rating; //NOT REQUIRED
@property (nonatomic, strong) NSArray *actors; //Type:string NOT REQUIRED
@property (nonatomic, strong) NSArray *directors; //Type:string NOT REQUIRED
@property (nonatomic, strong) NSString *itemDescription; //NB:description in specsNOT REQUIRED
@property (nonatomic, strong) NSArray *publishers; //NOT REQUIRED
@property (nonatomic, strong) NSString *language; //NOT REQUIRED
@property (nonatomic, strong) NSArray *relations; //NOT REQUIRED
@end
