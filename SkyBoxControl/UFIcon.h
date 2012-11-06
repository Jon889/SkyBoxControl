//
//  UFIcon.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 31/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFIcon : NSObject
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *depth;
@property (nonatomic, strong) NSURL *url;
//-(NSImage *)syncGetImage;
//-(BOOL)asyncGetIMage:!callbackblock!;
@end
