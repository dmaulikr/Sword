//
//  Spitter.h
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@class HelloWorldLayer;

@interface Spitter : CCSprite {
    float attackRate;
}

@property (nonatomic) bool attacking;
@property (nonatomic) int hp;
@property (nonatomic,weak) HelloWorldLayer *theGame;

- (id) initWithFile:(NSString *)filename TheGame:(HelloWorldLayer *)_game;

- (void) playerInRange:(CGRect)_playerBox;
- (void) startAttack;
- (void) attack;
- (void) die:(int)_direction;
- (void) hit:(float)_playerX;

- (CGRect) visionBoundingBox;

@end
