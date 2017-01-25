//
//  Bird.m
//  Duelist
//
//  Created by freddy on 07/10/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Bird.h"

#import "SimpleAudioEngine.h"

@implementation Bird

@synthesize theGame, hp;

-(id)initWithFile:(NSString *)filename
{
    if (self = [super initWithFile:filename]) {
        // init variables
    }
    return self;
}
-(id)initWithTheGame:(HelloWorldLayer *)_game {
    if (self = [super initWithFile:@"bird.png"]) {
        // init variables
        self.theGame = _game;
        self.hp = 1;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"birdActions.plist"];
         
         CCSpriteBatchNode *spriteSheetBird = [CCSpriteBatchNode batchNodeWithFile:@"birdActions.png"];
         [self.theGame addChild:spriteSheetBird];
         
         /*NSMutableArray *spitterAnimFrames = [NSMutableArray array];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic1.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic2.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic3.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic2.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic1.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic4.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic5.png"]];
         [spitterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SpitterStatic4.png"]];
         
         CCAnimation *moveAnim = [CCAnimation
         animationWithSpriteFrames:spitterAnimFrames delay:0.15f];
         
         CCAction *move = [CCRepeatForever actionWithAction:
         [CCAnimate actionWithAnimation:moveAnim]];
         [self runAction:move];*/
    }
    return self;
}

- (void) startAttack {
    // remove self from screen add self as projectile flying
    [self.theGame addBirdAttack:self Direction:self.scaleX];
    [[SimpleAudioEngine sharedEngine] playEffect:@"ptero.m4a"];
}

- (void) playerInRange:(CGRect)_playerBox {
    
    CGPoint playerOrig = _playerBox.origin;
    if ( playerOrig.x < self.position.x ) {
        self.scaleX = -1;
    }
    else {
        self.scaleX = 1;
    }
    
    [self startAttack];
    
}

- (CGRect) visionBoundingBox {
    return CGRectInset(self.boundingBox, -180, -60);
}

@end
