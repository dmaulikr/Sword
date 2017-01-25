//
//  Boss2.m
//  Duelist
//
//  Created by freddy on 24/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Boss2.h"


@implementation Boss2 {
    NSArray *locations;
    CCAction *hurtAction, *attackAction, *dieAction;
}

- (id) initWithFile:(HelloWorldLayer *)_game Locations:(NSArray *)_locations {
    
    if (self = [super initWithFile:@"Boss2.png"]) {
        // init variables
        self.theGame = _game;
        attackRate = 2.2;
        self.hp = 12;
        self.attacking = NO;
        locations = _locations;
        /*locations = [NSArray arrayWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:200.0f], [NSNumber numberWithFloat:160.0f], nil], [NSArray arrayWithObjects:[NSNumber numberWithFloat:320.0f], [NSNumber numberWithFloat:140.0f], nil], [NSArray arrayWithObjects:[NSNumber numberWithFloat:250.0f], [NSNumber numberWithFloat:220.0f], nil], nil];*/
        [self setupAnimations];
        [self schedule:@selector(move) interval:6.0];
    }
    return self;
    
}

- (void) setupAnimations {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Boss2Actions.plist"];
    
    CCSpriteBatchNode *spriteSheetBoss = [CCSpriteBatchNode batchNodeWithFile:@"Boss2Actions.png"];
    [self.theGame addChild:spriteSheetBoss];
    
    NSMutableArray *bossAttackAnimFrames = [NSMutableArray array];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Attack1.png"]];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Attack2.png"]];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Attack3.png"]];
    
    CCAnimation *attackAnim = [CCAnimation
                               animationWithSpriteFrames:bossAttackAnimFrames delay:0.15f];
    
    attackAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:attackAnim] times:1];
    
    NSMutableArray *bossHurtAnimFrames = [NSMutableArray array];
    [bossHurtAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Hurt1.png"]];
    [bossHurtAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Hurt2.png"]];
    [bossHurtAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Hurt1.png"]];
    
    CCAnimation *hurtAnim = [CCAnimation
                             animationWithSpriteFrames:bossHurtAnimFrames delay:0.2f];
    
    hurtAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:hurtAnim] times:1];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Boss2DieAnim.plist"];
    
    CCSpriteBatchNode *spriteSheetBossDie = [CCSpriteBatchNode batchNodeWithFile:@"Boss2DieAnim.png"];
    [self.theGame addChild:spriteSheetBossDie];
    
    NSMutableArray *bossDieFrames = [NSMutableArray array];
    for ( int i = 1; i <= 7; i++ ) {
        [bossDieFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Boss2Die%d.png",i]]];
    }
    
    CCAnimation *dieAnim = [CCAnimation animationWithSpriteFrames:bossDieFrames delay:0.12f];
    dieAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:dieAnim] times:1];
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
    id fadeAction = [CCFadeTo actionWithDuration:1.2 opacity:0.1];
    
    [self runAction:
     [CCSequence actions:
      dieAct, [CCCallFunc actionWithTarget:self selector:@selector(showParticles)], fadeAction, removeMySprite,
      nil]];
    [self.theGame bossToppled];
}

-(void)showParticles {
    [self.theGame showBossDeathParticles:self.position Layer:self.zOrder];
}

- (void) hit:(float)_playerX {
    self.attacking = NO;
    [self unschedule:@selector(attack)];
    [self unschedule:@selector(move)];
    [self stopAllActions];
    // Set new position from predetermined array positions - check if same as current
    bool differentPosition = NO;
    CGPoint newPoints;
    
    while (differentPosition == NO) {
        NSArray *coords = [locations objectAtIndex:arc4random()%([locations count]-1)];
        if ( [[coords objectAtIndex:0] floatValue] != self.position.x ) {
            differentPosition = YES;
            newPoints = ccp([[coords objectAtIndex:0] floatValue], [[coords objectAtIndex:1] floatValue]);
        }
    }
    
    self.position = ccp(newPoints.x, newPoints.y);
    [self schedule:@selector(move) interval:6.0];
    id aniaction = hurtAction;
    [self runAction:[CCSequence actions:aniaction, [CCCallFuncO actionWithTarget:self selector:@selector(setDisplayFrame:) object:[CCSpriteFrame frameWithTextureFilename:@"Boss2.png" rect:CGRectMake(0, 0, 25, 45)]], nil]];
    //Hit animation
}
- (void) move {
    
    // Maybe tint sprite during move adn/or hit.
    self.attacking = NO;
    [self unschedule:@selector(attack)];
    [self stopAllActions];
    
    bool differentPosition = NO;
    CGPoint newPoints;
    
    while (differentPosition == NO) {
        NSArray *coords = [locations objectAtIndex:arc4random()%([locations count]-1)];
        if ( [[coords objectAtIndex:0] floatValue] != self.position.x ) {
            differentPosition = YES;
            newPoints = ccp([[coords objectAtIndex:0] floatValue], [[coords objectAtIndex:1] floatValue]);
        }
    }
    
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss2Move.png"]];
    
    id moveAction = [CCMoveTo actionWithDuration:1.2 position:newPoints];
    [self runAction:[CCSequence actions:moveAction, [CCCallFuncO actionWithTarget:self selector:@selector(setDisplayFrame:) object:[CCSpriteFrame frameWithTextureFilename:@"Boss2.png" rect:CGRectMake(0, 0, 25, 45)]], nil]];
    
}
- (void) attack {
    //id aniaction = attackAction;
    //[self runAction:[CCSequence actions:aniaction, [CCCallFunc actionWithTarget:self selector:@selector(sendAttack)], nil]];
    //[self.theGame addKnivesAttack:self.position Direction:self.scaleX];
    id attackAni = attackAction;
    id attackHimAction = [CCCallFunc actionWithTarget:self selector:@selector(sendAttack)];
    id delayTimeAction = [CCDelayTime actionWithDuration:0.1];
    [self runAction:[CCSequence actions:attackAni, attackHimAction, delayTimeAction, attackHimAction, delayTimeAction, attackHimAction, delayTimeAction, attackHimAction, [CCCallFuncO actionWithTarget:self selector:@selector(setDisplayFrame:) object:[CCSpriteFrame frameWithTextureFilename:@"Boss2.png" rect:CGRectMake(0, 0, 25, 45)]], nil]];
    //[self sendAttack];
}
- (void) sendAttack {
    //[self.theGame addKnivesAttack:self.position Direction:self.scaleX];
    [self.theGame addSingleSlimeAttack:self.position Direction:self.scaleX];
    //[self setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"Boss1.png" rect:CGRectMake(0, 0, 17, 50)]];
}

- (CGRect) visionBoundingBox {
    return CGRectInset(self.boundingBox, -280, -280);
}

@end
