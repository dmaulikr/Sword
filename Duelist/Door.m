//
//  Door.m
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Door.h"


@implementation Door

@synthesize level, spawnPoint;

- (id) initWithFile:(NSString *)filename Level:(int)_level Spawn:(int)_sPoint {
    if ( self = [super initWithFile:filename] ) {
        level = _level;
        spawnPoint = _sPoint;
    }
    return self;
}

@end
