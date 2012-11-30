//
//  SBCAppDelegate.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 29/10/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PXSourceList, PXListView;
@interface SBCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (weak) IBOutlet NSView *controlView;
@property (weak) IBOutlet PXListView *listView;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@end
