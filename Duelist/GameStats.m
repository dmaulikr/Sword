//
//  GameStats.m
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "GameStats.h"

@implementation GameStats {
    CCSprite *hp, *hpNub;
}

@synthesize theGame;

- (id) init {
    if ( self = [super init] ) {
        //suppliesCount = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"HP %d", suppliesCollected] fontName:@"Marker Felt" fontSize:22];
        //suppliesCount.position = ccp(100, 40);
        //[self addChild:suppliesCount];
    }
    return self;
}

- (id) initWithTheGame:(HelloWorldLayer *)_game HP:(int)_hp {
    
    if ( self = [super init] ) {        
        theGame = _game;
        
        /*CCLayer *bgColor = [CCLayerColor layerWithColor:ccc4(80, 80, 80, 170)];
        bgColor.scaleY = 0.2;
        bgColor.position = ccp(bgColor.position.x, 120);
        [self addChild:bgColor];*/
        
        hp = [[CCSprite alloc] initWithFile:@"hpBar.png" rect:CGRectMake(0, 0, 66, 14)];
        [self addChild:hp];
        
        hpNub = [[CCSprite alloc] initWithFile:@"hpBarEnd.png"];
        [self addChild:hpNub];
        
        CCSprite *hpBarCont = [[CCSprite alloc] initWithFile:@"hpContainer.png"];
        hpBarCont.position = ccp(406, 296);
        [self addChild:hpBarCont];
        
        hp.position = ccp(hpBarCont.position.x-4, hpBarCont.position.y);
        hpNub.position = ccp(hp.position.x+(hp.boundingBox.size.width/2)+(hpNub.boundingBox.size.width/2), hp.position.y);
    }
    return self;
    
}

- (void) incSupplies:(CCSprite*)_supply { // SUPPLIES SHOULD SIMPLY BE HP + 1 DON'T NEED TO BOTHER WITH THIS
    //suppliesCollected++;
    //[suppliesCount setString:[NSString stringWithFormat:@"Supplies x %d", suppliesCollected]];
    
    // DROP AND ROTATE ANIMATION
    //_supply.position = ccp(160+(suppliesCollected*20), 360);
    id dropIn = [[CCMoveBy alloc] initWithDuration:0.6 position:ccp(0, -90)];
    id rotateAction = [CCRotateBy actionWithDuration:0.1 angle:30];
    CCAction * action = [CCSequence actions:dropIn, rotateAction, nil];
    _supply.rotation = -30;
    //[self addChild:_supply z:suppliesCollected+10];
    [_supply runAction:action];
    
    //if ( suppliesCollected >= 3 ) {
        //[theGame gameOver:1];
    //}
}

- (void)  updateBar:(int)_hp {
    //id bigger = [CCScaleBy actionWithDuration:0.2 scale:1.5];
    //id smaller = [CCScaleBy actionWithDuration:0.4 scale:0.6666];
    //[hpBar runAction:[CCSequence actions:bigger, smaller, nil]];
    float hpX = 402.0-((5-_hp)*6.0);
    float scaleVal = _hp/5.0f;
    [hp setScaleX:scaleVal];
    hp.position = ccp(hpX, hp.position.y);
    hpNub.position = ccp(hp.position.x+(hp.boundingBox.size.width/2)+(hpNub.boundingBox.size.width/2), hp.position.y);
}

@end
