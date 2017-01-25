//
//  RelicFoundView.m
//  Duelist
//
//  Created by freddy on 17/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "RelicFoundView.h"


@implementation RelicFoundView

@synthesize theGame;

- (id) initWithRelic:(NSString *)_relicName Description:(NSString *)_desc Game:(HelloWorldLayer *)_theGame {
    if ( self = [super init] ) {
        theGame = _theGame;
        
        CCSprite *bg = [[CCSprite alloc] initWithFile:@"relicFind.png"];
        bg.position = ccp(self.position.x, self.position.y);
        [self addChild:bg];
        
        CCSprite *relic = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"%@Large.png",_relicName]];
        relic.position = ccp(bg.position.x, bg.position.y+20);
        [self addChild:relic];
        
        id rotateC = [CCRotateTo actionWithDuration:0.6 angle:15];
        id rotateCC = [CCRotateTo actionWithDuration:0.6 angle:-15];
        id wobbleSeq = [CCSequence actions:rotateC, rotateCC, nil];
        id wobbleAction = [CCRepeatForever actionWithAction:wobbleSeq];
        [relic runAction:wobbleAction];
        
        CCLabelTTF *descLabel = [[CCLabelTTF alloc] initWithString:_desc fontName:@"Marker Felt" fontSize:13];
        descLabel.dimensions = CGSizeMake(270, 120);
        descLabel.position = ccp(bg.position.x, bg.position.y-96);
        [self addChild:descLabel];
        
        self.position = ccp(-300, 150);
        [self performSelector:@selector(spinIn) withObject:nil afterDelay:0.1];
    }
    return self;
}

- (void) spinIn {
    id action = [CCSpawn actions: [CCRotateBy actionWithDuration:1.2 angle:360],
                 [CCMoveBy actionWithDuration:1.2 position:ccp(540, 0)], nil];
    id ready = [CCCallFuncN actionWithTarget:theGame selector:@selector(relicVisible)];
    
    [self runAction:[CCSequence actions:action, ready, nil]];
    
    //[self performSelector:@selector(dismissed) withObject:nil afterDelay:6.0f];
}

- (void) dismissed {
    [self stopAllActions];
    
    id action = [CCSpawn actions: [CCRotateBy actionWithDuration:1.2 angle:450],
                 [CCMoveBy actionWithDuration:1.2 position:ccp(500, 0)],
                 [CCScaleBy actionWithDuration:1.0 scale:0.8], nil];
    
    id removeMySprite = [CCCallFuncND actionWithTarget:self
                                              selector:@selector(removeFromParentAndCleanup:)
                                                  data:(void*)NO];
    
    [self runAction:
     [CCSequence actions:
      action, removeMySprite,
      nil]];
}

@end
