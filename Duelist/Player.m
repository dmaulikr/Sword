//
//  Player.m
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "Player.h"
#import "SimpleAudioEngine.h"

@implementation Player {
    ccColor3B myColor;
    bool jumpedAgain;
    int hpMax;
}

@synthesize velocity = _velocity;
@synthesize desiredPosition = _desiredPosition;
@synthesize onGround = _onGround;
@synthesize forwardMarch = _forwardMarch, mightAsWellJump = _mightAsWellJump, backwardJaunt = _backwardJaunt;
@synthesize doneJumping = _doneJumping;
@synthesize canDoubleJump = _canDoubleJump;
@synthesize hurting, hp, attacking;
@synthesize extraJumps, detachedWall, hasClimbSpikes, climbing, hasDogAmulet, isDog, hasVisionBandana;

-(id)initWithFile:(NSString *)filename
{
    if (self = [super initWithFile:filename]) {
        self.velocity = ccp(0.0, 0.0);
        self.doneJumping = YES;
        self.hurting = NO;
        hpMax = 5;
        self.hp = hpMax;
        jumpedAgain = NO;
        myColor = self.color;
        self.detachedWall = NO;
        self.climbing = NO;
        self.extraJumps = 0;
        self.isDog = NO;
        self.hasDogAmulet = NO;
        self.hasVisionBandana = NO;
    }
    return self;
}

-(void)update:(ccTime)dt {
    CGPoint gravity = ccp(0.0, -450.0);
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    CGPoint forwardMove = ccp(800.0, 0.0);
    CGPoint forwardStep = ccpMult(forwardMove, dt); //1
    
    CGPoint backwardMove = ccp(-800.0, 0.0);
    CGPoint backwardStep = ccpMult(backwardMove, dt); //1
    
    self.velocity = ccpAdd(self.velocity, gravityStep);
    self.velocity = ccp(self.velocity.x * 0.90, self.velocity.y); //2
    
    CGPoint jumpForce = ccp(0.0, 310.0);
    float jumpCutoff = 150.0;
    
    
    if ( !self.climbing ) {
        // JUMPING LOGIC - ALLOW SINGLE AND DOUBLE JUMPS (WITH RELIC)
        if (self.mightAsWellJump && self.onGround) {
            
            self.extraJumps = 0;
            self.doneJumping = NO;
            jumpedAgain = NO;
            self.velocity = ccpAdd(self.velocity, jumpForce);
            [[SimpleAudioEngine sharedEngine] playEffect:@"woosh.mp3"];
            
        } else if ( !self.doneJumping && self.canDoubleJump && self.extraJumps == 1 && !jumpedAgain ) {
            
            self.velocity = ccpAdd(self.velocity, jumpForce);
            jumpedAgain = YES;
            [[SimpleAudioEngine sharedEngine] playEffect:@"woosh.mp3"];
            
        } else if (!self.mightAsWellJump && self.velocity.y > jumpCutoff) {
            
            self.velocity = ccp(self.velocity.x, jumpCutoff);
            
        }
        
    }
    
    if ( self.forwardMarch ) {
        self.velocity = ccpAdd(self.velocity, forwardStep);
    }
    else if (self.backwardJaunt) {
        self.velocity = ccpAdd(self.velocity, backwardStep);
    }
    
    if ( self.climbing ) {
        CGPoint minMovement = ccp(-90.0, 0.0);
        CGPoint maxMovement = ccp(90.0, 0.0);
        self.velocity = ccpClamp(self.velocity, minMovement, maxMovement); //4
    }
    else {
        CGPoint minMovement = ccp(-140.0, -450.0);
        CGPoint maxMovement = ccp(140.0, 250.0);
        self.velocity = ccpClamp(self.velocity, minMovement, maxMovement); //4
    }
    
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    self.desiredPosition = ccpAdd(self.position, stepVelocity);
    
    //if ( self.hurting == NO ) {
        //self.color = myColor;
    //}
}

-(void)hit {
    self.hurting = YES;
    self.hp--;
    [self runAction:[CCSequence actions:
                       [CCTintTo actionWithDuration:1.0 red:255 green:0 blue:0], nil]];
    [self performSelector:@selector(painOver) withObject:nil afterDelay:1.2];
}
-(void)painOver {
    self.hurting = NO;
    self.color = myColor;
}

-(void)incHp {
    if ( self.hp < hpMax ) {
        self.hp++;
    }
}

-(void)transmute {
    if ( self.isDog ) {
        self.isDog = NO;
        self.position = ccp(self.position.x,self.position.y+20);
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DuelistPlayer.png"]];
    }
    else {
        self.isDog = YES;
        [self setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"DuelistPlayerDog.png" rect:CGRectMake(0, 0, 22, 15)]];
    }
}

-(CGRect)collisionBoundingBox {
    if ( self.isDog ) {
        CGRect collisionBox = CGRectInset(self.boundingBox, 2, 2);
        CGPoint diff = ccpSub(self.desiredPosition, self.position);
        CGRect returnBoundingBox = CGRectOffset(collisionBox, diff.x, diff.y);
        return returnBoundingBox;
    }
    else {
        CGRect collisionBox = CGRectInset(self.boundingBox, 14, 2);
        CGPoint diff = ccpSub(self.desiredPosition, self.position);
        CGRect returnBoundingBox = CGRectOffset(collisionBox, diff.x, diff.y);
        return returnBoundingBox;
    }
}
-(CGRect)swordBoundingBox {
    CGRect collisionBox = CGRectInset(self.boundingBox, 10, 20);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, 16*self.scaleX, 0);
    return returnBoundingBox;
}
-(CGRect)doorBoundingBox {
    CGRect collisionBox = CGRectInset(self.boundingBox, 10, 6);
    return collisionBox;
}
-(CGRect)climbBoundingBox {
    CGRect collisionBox = CGRectInset(self.boundingBox, 20, 0);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, 2*self.scaleX, 0);
    return returnBoundingBox;
}
-(CGRect)projectileBoundingBox {
    CGRect collisionBox = CGRectInset(self.boundingBox, 10, 3);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, 0, -3);
    return returnBoundingBox;
}

@end
