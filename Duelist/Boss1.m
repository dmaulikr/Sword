//
//  Boss1.m
//  Duelist
//
//  Created by freddy on 19/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Boss1.h"

@implementation Boss1 {
    float minX, maxX;
    CCAction *hurtAction, *attackAction, *dieAction;
}

@synthesize hp, attacking;

- (id) initWithFile:(HelloWorldLayer *)_game BoundX:(float)_minX BoundX2:(float)_maxX {
    
    if (self = [super initWithFile:@"Boss1.png"]) {
        // init variables
        self.theGame = _game;
        attackRate = 1.8;
        self.hp = 10;
        self.attacking = NO;
        minX = _minX;
        maxX = _maxX;
        [self setupAnimations];
    }
    return self;
    
}

- (void) setupAnimations {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Boss1Actions.plist"];
    
    CCSpriteBatchNode *spriteSheetBoss = [CCSpriteBatchNode batchNodeWithFile:@"Boss1Actions.png"];
    [self.theGame addChild:spriteSheetBoss];
    
    NSMutableArray *bossAttackAnimFrames = [NSMutableArray array];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss1Attack1.png"]];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss1Attack2.png"]];
    [bossAttackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Boss1Attack1.png"]];
    
    CCAnimation *attackAnim = [CCAnimation
                             animationWithSpriteFrames:bossAttackAnimFrames delay:0.1f];
    
    attackAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:attackAnim] times:1];
    
    NSMutableArray *bossHurtAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        [bossHurtAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Boss1Hurt%d.png",i]]];
    }
    
    CCAnimation *hurtAnim = [CCAnimation
                               animationWithSpriteFrames:bossHurtAnimFrames delay:0.2f];
    
    hurtAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:hurtAnim] times:1];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Boss1DieAnim.plist"];
    
    CCSpriteBatchNode *spriteSheetBossDie = [CCSpriteBatchNode batchNodeWithFile:@"Boss1DieAnim.png"];
    [self.theGame addChild:spriteSheetBossDie];
    
    NSMutableArray *bossDieFrames = [NSMutableArray array];
    for ( int i = 1; i <= 7; i++ ) {
        [bossDieFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Boss1Die%d.png",i]]];
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
    // MOVE WITHIN BOUNDS AND PUFF SMOKE
    float newX = arc4random() % 200 + 30;
    if ( _playerX > (maxX - ((maxX-minX)/2)) ) {
        newX = minX+newX;
    }
    else {
        newX = maxX-newX;
    }
    self.position = ccp(newX, self.position.y);
    id aniaction = hurtAction;
    [self runAction:[CCSequence actions:aniaction, [CCCallFuncO actionWithTarget:self selector:@selector(setDisplayFrame:) object:[CCSpriteFrame frameWithTextureFilename:@"Boss1.png" rect:CGRectMake(0, 0, 17, 50)]], nil]];
}
- (void) attack {
    id aniaction = attackAction;
    [self runAction:[CCSequence actions:aniaction, [CCCallFunc actionWithTarget:self selector:@selector(sendAttack)], nil]];
    //[self.theGame addKnivesAttack:self.position Direction:self.scaleX];
}
- (void) sendAttack {
    [self.theGame addKnivesAttack:self.position Direction:self.scaleX];
    [self setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"Boss1.png" rect:CGRectMake(0, 0, 17, 50)]];
}

- (CGRect) visionBoundingBox {
    return CGRectInset(self.boundingBox, -250, -100);
}

@end
