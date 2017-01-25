//
//  Spitter.m
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Spitter.h"

#import "SimpleAudioEngine.h"

@implementation Spitter {
    CCAction *dieAction;
}

@synthesize attacking, theGame, hp;

-(id)initWithFile:(NSString *)filename
{
    if (self = [super initWithFile:filename]) {
        // init variables
        attackRate = 0.8;
        attacking = NO;
    }
    return self;
}
-(id)initWithFile:(NSString *)filename TheGame:(HelloWorldLayer *)_game
{
    if (self = [super initWithFile:filename]) {
        // init variables
        self.theGame = _game;
        attackRate = 0.8;
        self.hp = 1;
        self.attacking = NO;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SpitterAnis.plist"];
        
        CCSpriteBatchNode *spriteSheetSpitter = [CCSpriteBatchNode batchNodeWithFile:@"SpitterAnis.png"];
        [self.theGame addChild:spriteSheetSpitter];
        
        NSMutableArray *spitterDieFrames = [NSMutableArray array];
        for ( int i = 1; i <= 5; i++ ) {
            [spitterDieFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"SpitterDie%d.png",i]]];
        }
        
        CCAnimation *dieAnim = [CCAnimation animationWithSpriteFrames:spitterDieFrames delay:0.12f];
        dieAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:dieAnim] times:1];
        
        NSMutableArray *spitterAnimFrames = [NSMutableArray array];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic1.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic2.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic3.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic2.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic1.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic4.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic5.png"]];
        [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic4.png"]];
        
        CCAnimation *moveAnim = [CCAnimation animationWithSpriteFrames:spitterAnimFrames delay:0.15f];
        CCAction *move = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:moveAnim]];
        [self runAction:move];
    }
    return self;
}

- (void) startAttack {
    self.attacking = YES;
    [self schedule:@selector(attack) interval:attackRate];
}
- (void) attack {
    [self.theGame addProjectile:self.position Target:ccp(self.position.x+(420*self.scaleX), self.position.y)];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Splasher.m4a"];
}

- (void) die:(int)_direction {
    [self unschedule:@selector(attack)];
    [self stopAllActions];
    
    /*id action = [CCSpawn actions: [CCRotateBy actionWithDuration:0.3 angle:180*_direction],
                 [CCMoveBy actionWithDuration:0.3 position:ccp(80*_direction, 35)],
                 [CCTintTo actionWithDuration:0.25 red:150 green:0 blue:0], nil];*/
    
    //id rotateAction = [CCRotateBy actionWithDuration:0.6 angle:180*_direction];
    //id tintAction = [CCTintTo actionWithDuration:0.4 red:150 green:0 blue:0];
    //id delayTimeAction = [CCDelayTime actionWithDuration:0.2];
    id removeMySprite = [CCCallFuncND actionWithTarget:self
                                              selector:@selector(removeFromParentAndCleanup:)
                                                  data:(void*)NO];
    
    id dieAct = dieAction;
    id fadeAction = [CCFadeTo actionWithDuration:0.3 opacity:0.1];
    
    [self runAction:
     [CCSequence actions:
      dieAct, fadeAction, removeMySprite,
      nil]];
}
- (void) hit:(float)_playerX {
    // SPITTER DOESN'T CARE!!
}

- (void) playerInRange:(CGRect)_playerBox {
    
    CGPoint playerOrig = _playerBox.origin;
    if ( playerOrig.x < self.position.x ) {
        self.scaleX = -1;
    }
    else {
        self.scaleX = 1;
    }
    
    if ( self.attacking == NO ) {
        [self startAttack];
    }
    
}

- (CGRect) visionBoundingBox {
    return CGRectInset(self.boundingBox, -100, -45);
}

@end
