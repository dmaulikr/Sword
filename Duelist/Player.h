//
//  Player.h
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCSprite {
    
}

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround, doneJumping;
@property (nonatomic, assign) BOOL forwardMarch, backwardJaunt;
@property (nonatomic, assign) BOOL mightAsWellJump;
@property (nonatomic) bool hurting, attacking, canDoubleJump, hasClimbSpikes, detachedWall, climbing, hasDogAmulet, isDog, hasVisionBandana;
@property (nonatomic) int hp, extraJumps;

-(void)update:(ccTime)dt;
-(void)hit;
-(void)incHp;
-(void)transmute;

-(CGRect)collisionBoundingBox;
-(CGRect)swordBoundingBox;
-(CGRect)doorBoundingBox;
-(CGRect)climbBoundingBox;
-(CGRect)projectileBoundingBox;

@end
