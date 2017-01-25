//
//  HomeScreenLayer.m
//  Duelist
//
//  Created by freddy on 17/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import "HomeScreenLayer.h"

#import "HelloWorldLayer.h"

#import "GameStateManager.h"
#import "SimpleAudioEngine.h"


@implementation HomeScreenLayer {
    CCSprite *newGame, *continueGame;
    bool gameExists;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HomeScreenLayer *layer = [HomeScreenLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
        
        gameExists = NO;
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"gameExists"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"gameExists"] == YES ) {
            gameExists = YES;
        }
        
        self.touchEnabled = YES;
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Delerium.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"AngryMod.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"swordSwing.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"woosh.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Splasher.m4a"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ptero.m4a"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bossIntro.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bossDeath.mp3"];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg = [[CCSprite alloc] initWithFile:@"HomeBg.png"];
        bg.position = ccp(size.width-125, size.height-125);
        [self addChild:bg];
        
        newGame = [[CCSprite alloc] initWithFile:@"newGame.png"];
        [newGame setPosition:ccp(size.width/2 - 30, size.height/2 + 50)];
        [self addChild:newGame];
        
        continueGame = [[CCSprite alloc] initWithFile:@"continueGame.png"];
        [continueGame setPosition:ccp(size.width/2 + 30, size.height/2 - 50)];
        if ( !gameExists ) { continueGame.opacity = 120; }
        [self addChild:continueGame];
        
    }
    return self;
}

- (void) startGame {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Delerium.mp3" loop:YES];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *t in touches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        if ( CGRectContainsPoint([newGame boundingBox], touchLocation) ) {
            [[GameStateManager sharedInstance] resetGame];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"gameExists"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self startGame];
        }
        else if ( CGRectContainsPoint([continueGame boundingBox], touchLocation) && gameExists ) {
            [self startGame];
        }
    }
}

@end
