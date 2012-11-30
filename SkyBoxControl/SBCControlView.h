//
//  SBCControlView.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 28/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SBCControlView;
@protocol SBCControlViewDelegate
-(void)controlView:(SBCControlView *)cview changedSpeedValue:(NSString*)sv;
@end
@interface SBCControlView : NSView
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, assign) IBOutlet id delegate;
@end
