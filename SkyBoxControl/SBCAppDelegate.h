//
//  SBCAppDelegate.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PXSourceList;
@interface SBCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet PXSourceList *sourceList;
@property (weak) IBOutlet NSTextField *startMessage;
@property (weak) IBOutlet NSView *controlView;

@end
