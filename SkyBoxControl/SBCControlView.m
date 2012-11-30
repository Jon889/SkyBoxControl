//
//  SBCControlView.m
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 28/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "SBCControlView.h"

@interface NSBezierPath (SBCExt)
@end
@implementation NSBezierPath (SBCExt)
+(NSBezierPath *)bezierPathWithEquilateralTriangleInSquareRect:(NSRect)rect {
	if (rect.size.width != rect.size.height) {
		return nil;
	}
	NSBezierPath *triangle = [NSBezierPath bezierPath];
	CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
	CGFloat radius = rect.size.height/2;
	CGFloat yMag = sqrt(pow(radius, 2) - pow(radius/2, 2));
	[triangle moveToPoint:NSMakePoint(center.x + radius, center.y)];
	[triangle lineToPoint:NSMakePoint(center.x - radius/2, center.y + yMag)];
	[triangle lineToPoint:NSMakePoint(center.x - radius/2, center.y - yMag)];
	[triangle closePath];
	return triangle;
}
+(NSBezierPath *)bezierPathWithPauseSymbol:(NSRect)recti {
	NSRect rect = CGRectInset(recti, recti.size.width/6, recti.size.height/6);
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
	CGFloat radius = rect.size.height/2;
	CGFloat yMag = sqrt(pow(radius, 2) - pow(radius/2, 2));
	[path appendBezierPathWithRect:NSMakeRect(rect.origin.x, center.y - yMag, rect.size.width/3, yMag*2)];
	[path appendBezierPathWithRect:NSMakeRect(rect.origin.x+ 2*rect.size.width/3, center.y - yMag, rect.size.width/3, yMag*2)];
	return path;
}
@end
@implementation SBCControlView {
	BOOL mouseIsDown;
	BOOL showBackground;
	CGPoint dragPoint;
	int leftHover;
	int rightHover;
}
+(NSArray *)leftSpeeds {
	return @[@"-30", @"-12", @"-6", @"-2"];
}
+(NSArray *)rightSpeeds {
	return @[@"2", @"6", @"12", @"30"];
}
-(CGFloat)leftWidth {
	return [self leftRect].size.width/[[[self class] leftSpeeds] count];
}
-(CGFloat)rightWidth {
	return [self rightRect].size.width/[[[self class] rightSpeeds] count];
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)mouseDragged:(NSEvent *)theEvent {
	if (mouseIsDown) {
		showBackground = YES;
		CGPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		leftHover = localPoint.x/[self leftWidth];
		rightHover = (localPoint.x-CGRectGetMinX([self rightRect]))/[self rightWidth];
		dragPoint = localPoint;
		[self setNeedsDisplay:YES];
	}
}
-(void)mouseDown:(NSEvent *)theEvent {
	if (CGRectContainsPoint([self centreRect], [self convertPoint:[theEvent locationInWindow] fromView:nil])) {
		mouseIsDown = YES;
		[self setNeedsDisplay:YES];
	}
}

-(void)mouseUp:(NSEvent *)theEvent {
	CGPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSString *speedString = nil;
	if (CGRectContainsPoint([self centreRect], localPoint)) {
		speedString = (self.isPlaying) ? @"0" : @"1";
	}
	int leftUp = (int)localPoint.x/(int)[self leftWidth];
	int rightLocal = localPoint.x-CGRectGetMinX([self rightRect]);
	int rightUp = rightLocal/(int)[self rightWidth];
	if (leftUp < [[[self class] leftSpeeds] count] && leftUp >= 0) {
		speedString = [[[self class] leftSpeeds] objectAtIndex:leftUp];
	}
	if (rightUp < [[[self class] rightSpeeds] count] && rightUp >= 0 && rightLocal >= 0) {
		speedString = [[[self class] rightSpeeds] objectAtIndex:rightUp];
	}
	if (speedString) {
		[self.delegate controlView:self changedSpeedValue:speedString];
	}
	mouseIsDown = NO;
	showBackground = NO;
	dragPoint = CGPointMake(-1, -1);
	[self setNeedsDisplay:YES];
}
-(NSRect)centreRect {
	CGFloat height = self.bounds.size.height;
	return NSMakeRect(self.bounds.size.width/2 - height/2, 0, height, height);
}
-(NSRect)rightRect {
	CGFloat x = CGRectGetMaxX([self centreRect]);
	return NSMakeRect(x, 0, self.bounds.size.width - x, self.bounds.size.height);
}
-(NSRect)leftRect {
	CGFloat x = CGRectGetMinX([self centreRect]);
	return NSMakeRect(0, 0, x, self.bounds.size.height);
}

- (void)drawRect:(NSRect)dirtyRect {
	CGFloat height = self.bounds.size.height;
	CGPoint center = CGPointMake(self.bounds.size.width/2, height/2);
	if (showBackground) {
		NSBezierPath *rect = [NSBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0, 5) xRadius:height/4 yRadius:height/2];
		[[NSColor colorWithCalibratedRed:0 green:0 blue:0.7 alpha:1] setFill];
		[rect fill];
		int i = 0;
		for (NSString *speed in [[self class] leftSpeeds]) {
			NSDictionary *attrib = @{NSForegroundColorAttributeName : [NSColor whiteColor]};
			if (i == leftHover) {
				attrib = @{NSForegroundColorAttributeName : [NSColor redColor]};
			}
			[speed drawAtPoint:NSMakePoint([self leftRect].origin.x + i*[self leftWidth], self.bounds.size.height/2 - [speed sizeWithAttributes:attrib].height/2) withAttributes:attrib];
			i++;
		}
		
		int ri = 0;
		for (NSString *speed in [[self class] rightSpeeds]) {
			NSDictionary *attrib = @{NSForegroundColorAttributeName : [NSColor whiteColor]};
			if (ri == rightHover) {
				attrib = @{NSForegroundColorAttributeName : [NSColor redColor]};
			}
			[speed drawAtPoint:NSMakePoint([self rightRect].origin.x + ri*[self rightWidth], self.bounds.size.height/2 - [speed sizeWithAttributes:attrib].height/2) withAttributes:attrib];
			ri++;
		}
	}
	NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:[self centreRect]];
	[[NSColor blueColor] setFill];
	[circlePath fill];
	
	NSRect r = CGRectInset([self centreRect], 5, 5);
	NSBezierPath *playpause = (self.isPlaying) ? [NSBezierPath bezierPathWithPauseSymbol:r] : [NSBezierPath bezierPathWithEquilateralTriangleInSquareRect:r];
	
	if (CGRectContainsPoint([self centreRect], dragPoint)) {
		[[NSColor yellowColor] setFill];
	} else {
		[[NSColor whiteColor] setFill];
	}
	[playpause fill];
	
	
	
	
}

@end
