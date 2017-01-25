//
//  Relic.m
//  Duelist
//
//  Created by freddy on 16/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Relic.h"


@implementation Relic

@synthesize name;

- (id) initWithFile:(NSString *)filename Name:(NSString *)_name {
    if ( self = [super initWithFile:filename] ) {
        name = _name;
    }
    return self;
}

- (void) collected {
    id action = [CCSpawn actions: [CCRotateBy actionWithDuration:1.5 angle:25],
                 [CCMoveBy actionWithDuration:1.5 position:ccp(0, 180)],
                 [CCScaleBy actionWithDuration:1.5 scale:3.5], nil];
    
    id removeMySprite = [CCCallFuncND actionWithTarget:self
                                              selector:@selector(removeFromParentAndCleanup:)
                                                  data:(void*)NO];
    
    [self runAction:
     [CCSequence actions:
      action, removeMySprite,
      nil]];
}

@end
