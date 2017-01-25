//
//  GameStats.h
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@class HelloWorldLayer;

@interface GameStats : CCNode {
}

@property (nonatomic,weak) HelloWorldLayer *theGame;

-(id) initWithTheGame:(HelloWorldLayer *)_game HP:(int)_hp;

- (void) incSupplies:(CCSprite*)_supply;
- (void) updateBar:(int)_hp;

@end
