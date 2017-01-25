//
//  HelloWorldLayer.h
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright Freddie 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCTMXTiledMap *map, *bgIm;
}

@property (nonatomic, strong) CCAction *walkAction, *jumpAction, *climbAction, *attackAction, *staticAction, *dogRunAction, *dieAction;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)gameOver:(BOOL)won;
-(void)addProjectile:(CGPoint)_origin Target:(CGPoint)_target;
-(void)addKnivesAttack:(CGPoint)_origin Direction:(int)_dir;
-(void)addSingleSlimeAttack:(CGPoint)_origin Direction:(int)_dir;
-(void)addBirdAttack:(NSObject*)_bird Direction:(int)_dir;
-(void)relicVisible;
-(void)bossToppled;
-(void)showBossDeathParticles:(CGPoint)_bossLocal Layer:(int)_zPos;

@end
