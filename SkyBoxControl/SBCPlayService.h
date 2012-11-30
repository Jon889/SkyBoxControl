//
//  SBCPlayService.h
//  SkyBoxControl
//
//  Created by Jonathan Bailey on 10/11/2012.
//  Copyright (c) 2012 Jonathan Bailey. All rights reserved.
//

#import "UFService.h"

@interface SBCPlayService : UFService
-(void)play;
-(void)pause;
-(void)fastForward;
-(void)rewind;
-(void)playbackAtSpeed:(NSInteger)speed;
@end
