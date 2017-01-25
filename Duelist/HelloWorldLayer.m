//
//  HelloWorldLayer.m
//  Duelist
//
//  Created by freddy on 10/09/2013.
//  Copyright Freddie 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GameStateManager.h"
#import "SimpleAudioEngine.h"

#import "Player.h"
#import "Spitter.h"
#import "Bird.h"
#import "Boss1.h"
#import "Boss2.h"
#import "Door.h"
#import "Relic.h"

#import "GameStats.h"
#import "RelicFoundView.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer {
    Player *player;
    GameStats *gameStats;
    RelicFoundView *relicFound;
    CCTMXLayer *walls, *hazards, *pickups, *falseWalls;
    CCSprite *left, *right, *action, *actionB, *actionX;
    NSMutableArray *enemies, *projectiles, *doors, *relics, *climbTiles;
    NSString *nextAudio;
    float scaleF;
    BOOL gameOver, relicViewActive, resetDoors, inSmallSpace, fadingOut;
}

@synthesize walkAction, jumpAction, climbAction, attackAction, staticAction, dogRunAction, dieAction;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        self.touchEnabled = YES;
        [self loadAnimationActions];
        
        scaleF = CC_CONTENT_SCALE_FACTOR();
		
		CCLayerColor *blueSky = [[CCLayerColor alloc] initWithColor:ccc4(100, 100, 250, 255)];
        [self addChild:blueSky];
        
        int level = [[GameStateManager sharedInstance] getCurrentLevel];
        int spawn = [[GameStateManager sharedInstance] getSpawnPoint];
        int hp = [[GameStateManager sharedInstance] getHp];
        // USE IF GAME EXISTS TO CHECK IF NEW GAME
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"gameExists"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        bgIm = [[CCTMXTiledMap alloc] initWithTMXFile:[NSString stringWithFormat:@"duelBg%d.tmx",level]];
        [self addChild:bgIm];
        
        map = [[CCTMXTiledMap alloc] initWithTMXFile:[NSString stringWithFormat:@"duelLevel%d.tmx",level]];
        [self addChild:map];
        
        walls = [map layerNamed:@"walls"];
        hazards = [map layerNamed:@"hazards"];
        pickups = [map layerNamed:@"pickups"];
        falseWalls = [map layerNamed:@"falseWalls"];
        
        [[map layerNamed:@"falseWalls"] setZOrder:20];
        
        CCTMXObjectGroup *objectGroup = [map objectGroupNamed:@"spawns"];
        NSDictionary *playerSpawnDic = [objectGroup objectNamed:[NSString stringWithFormat:@"spawn%d",spawn]];
        int x = [playerSpawnDic[@"x"] integerValue];
        int y = [playerSpawnDic[@"y"] integerValue];
        
        player = [[Player alloc] initWithFile:@"DuelistPlayer.png"];
        player.position = ccp(x/scaleF, y/scaleF);
        player.canDoubleJump = [[GameStateManager sharedInstance] haveFoundThisRelic:@"doubleJump"];
        //player.canDoubleJump = YES;
        player.hasClimbSpikes = [[GameStateManager sharedInstance] haveFoundThisRelic:@"handSpikes"];
        //player.hasClimbSpikes = YES;
        player.hasDogAmulet = [[GameStateManager sharedInstance] haveFoundThisRelic:@"dogAmulet"];
        //player.hasDogAmulet = YES;
        player.hasVisionBandana = [[GameStateManager sharedInstance] haveFoundThisRelic:@"visionBandana"];
        //player.hasVisionBandana = YES;
        [map addChild:player z:15];
        player.hp = hp;
        
        if ( [map objectGroupNamed:@"blockers"] && player.hasVisionBandana ) {
            CCTMXObjectGroup *blockers = [map objectGroupNamed:@"blockers"];
            NSDictionary *blockerDic = [blockers objectNamed:@"blocker1"];
            CGPoint blockerPos = [self tileCoordForPosition:ccp([blockerDic[@"x"] integerValue]/scaleF, [blockerDic[@"y"] integerValue]/scaleF)];
            [walls removeTileAt:ccp(blockerPos.x, blockerPos.y-1)];
            [falseWalls setOpacity:120];
        }
        
        [self initEnemies];
        [self initDoorsRelicsClimbs];
        
        left = [CCSprite spriteWithFile:@"walkLeft.png"];
        left.position = ccp(30, 30);
        [self addChild:left];
        
        right = [CCSprite spriteWithFile:@"walkRight.png"];
        right.position = ccp(left.position.x+80, left.position.y);
        [self addChild:right];
        
        action = [CCSprite spriteWithFile:@"actionButtonA.png"];
        action.position = ccp(450, left.position.y+10);
        [self addChild:action];
        
        actionB = [CCSprite spriteWithFile:@"actionButtonB.png"];
        actionB.position = ccp(380, left.position.y);
        [self addChild:actionB];
        
        if ( player.hasDogAmulet ) {
            actionX = [CCSprite spriteWithFile:@"actionButtonX.png"];
            actionX.position = ccp(310, left.position.y);
            [self addChild:actionX];
        }
        
        gameStats = [[GameStats alloc] initWithTheGame:self HP:player.hp];
        if ( player.hp < 5 ) {
            [gameStats updateBar:player.hp];
        }
        [self addChild:gameStats];
        
        relicViewActive = NO;
        resetDoors = NO;
        inSmallSpace = NO;
        
        [self schedule:@selector(update:)];
        
	}
	return self;
}

- (void) initEnemies {
    
    if ( [[SimpleAudioEngine sharedEngine] backgroundMusicVolume] < 1.0f ) {
        [self crossFadeBGM:@"Delerium.mp3"];
    }
    
    projectiles = [NSMutableArray new];
    enemies = [NSMutableArray new];
    CCTMXObjectGroup *objectGroup = [map objectGroupNamed:@"enemies"];
    
    for ( NSDictionary *enDic in [objectGroup objects] ) {
        int x = [enDic[@"x"] integerValue];
        int y = [enDic[@"y"] integerValue];
        Spitter *spitter;
        if ( [enDic objectForKey:@"special"] ) {
            if ( [[GameStateManager sharedInstance] haveBeatenBoss:[[enDic objectForKey:@"special"] intValue]] == NO ) {
                [self crossFadeBGM:@"AngryMod.mp3"];
                if ( [[enDic objectForKey:@"special"] intValue] == 1 || [[enDic objectForKey:@"special"] intValue] == 3 ) {
                    spitter = [[Boss1 alloc] initWithFile:self BoundX:360.0 BoundX2:850.0];
                }
                else {
                    CCTMXObjectGroup *teleGroup = [map objectGroupNamed:@"teles"];
                    NSMutableArray *teles = [NSMutableArray new];
                    for ( NSDictionary *telDic in [teleGroup objects] ) {
                        [teles addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:[telDic[@"x"] floatValue]/scaleF], [NSNumber numberWithFloat:[telDic[@"y"] floatValue]/scaleF], nil]];
                    }
                    spitter = [[Boss2 alloc] initWithFile:self Locations:[NSArray arrayWithArray:teles]];
                }
                spitter.position = ccp(x/scaleF, y/scaleF);
                spitter.tag = 0;
                [map addChild:spitter z:50];
                [enemies addObject:spitter];
                [[SimpleAudioEngine sharedEngine] playEffect:@"bossIntro.mp3"];
            }
        }
        else {
            if ( [enDic objectForKey:@"bird"] ) {
                spitter = [[Bird alloc] initWithTheGame:self];
                spitter.position = ccp(x/scaleF, y/scaleF);
                spitter.tag = 0;
                [map addChild:spitter z:50];
                [enemies addObject:spitter];
            }
            else {
                spitter = [[Spitter alloc] initWithFile:@"Spitter.png" TheGame:self];
                spitter.position = ccp(x/scaleF, y/scaleF);
                spitter.tag = 0;
                [map addChild:spitter z:50];
                [enemies addObject:spitter];
            }
        }
        
    }

}
- (void) initDoorsRelicsClimbs {
    
    doors = [NSMutableArray new];
    CCTMXObjectGroup *objectGroup = [map objectGroupNamed:@"doors"];
    
    for ( NSDictionary *doDic in [objectGroup objects] ) {
        int x = [doDic[@"x"] integerValue];
        int y = [doDic[@"y"] integerValue];
        int doLevel = [doDic[@"level"] integerValue];
        int doSpawn = [doDic[@"spawn"] integerValue];
        NSString *fName = @"transDoor.png";
        if ( [doDic objectForKey:@"special"] ) { fName = @"transDoorBoss.png"; }
        if ( [doDic objectForKey:@"boss"] ) {
            if ( [[GameStateManager sharedInstance] haveBeatenBoss:[[doDic objectForKey:@"boss"] intValue]] == YES ) {
                Door *door = [[Door alloc] initWithFile:fName Level:doLevel Spawn:doSpawn];
                door.position = ccp(x/scaleF, y/scaleF);
                [map addChild:door z:45];
                [doors addObject:door];
            }
        }
        else {
            Door *door = [[Door alloc] initWithFile:fName Level:doLevel Spawn:doSpawn];
            door.position = ccp(x/scaleF, y/scaleF);
            [map addChild:door z:45];
            [doors addObject:door];
        }
    }
    
    relics = [NSMutableArray new];
    CCTMXObjectGroup *objectGroup2 = [map objectGroupNamed:@"relics"];
    
    for ( NSDictionary *relDic in [objectGroup2 objects] ) {
        NSString *relName = [relDic objectForKey:@"name"];
        
        if ( [[GameStateManager sharedInstance] haveFoundThisRelic:relName] == NO ) {
            int x = [relDic[@"x"] integerValue];
            int y = [relDic[@"y"] integerValue];
            Relic *relic = [[Relic alloc] initWithFile:[NSString stringWithFormat:@"%@.png",relName] Name:relName];
            relic.position = ccp(x/scaleF, y/scaleF);
            [map addChild:relic z:45];
            [relics addObject:relic];
        }
    }
    
    climbTiles = [NSMutableArray new];
    CCTMXObjectGroup *climbGroup = [map objectGroupNamed:@"climbing"];
    
    for ( NSDictionary *climDic in [climbGroup objects] ) {
        int x = [climDic[@"x"] integerValue];
        int y = [climDic[@"y"] integerValue];
        CCSprite *climber = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"%@.png",[climDic objectForKey:@"image"]]];
        climber.position = ccp(x/scaleF, y/scaleF);
        [map addChild:climber z:player.zOrder-1];
        [climbTiles addObject:climber];
    }
    
}

- (void) loadAnimationActions {
    
    // LOAD STANDING ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DuelPlayerStaticAnim.plist"];
    
    CCSpriteBatchNode *staticSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DuelPlayerStaticAnim.png"];
    [self addChild:staticSpriteSheet];
    
    NSMutableArray *standAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 2; i++) {
        [standAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerStatic%d.png",i]]];
    }
    
    CCAnimation *standAnim = [CCAnimation
                             animationWithSpriteFrames:standAnimFrames delay:0.42f];
    
    self.staticAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:standAnim]];
    
    // LOAD RUN ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DuelistRunAnim.plist"];
    
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DuelistRunAnim.png"];
    [self addChild:spriteSheet];
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerRun%d.png",i]]];
    }
    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DuelistPlayerRun2.png"]];
    
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.2f];
    
    self.walkAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:walkAnim]];
    
    // LOAD DOG RUN ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PlayerDogRunAnim.plist"];
    
    CCSpriteBatchNode *dogSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"PlayerDogRunAnim.png"];
    [self addChild:dogSpriteSheet];
    
    NSMutableArray *dRunAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 2; i++) {
        [dRunAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerDogRun%d.png",i]]];
    }
    
    CCAnimation *dRunAnim = [CCAnimation
                             animationWithSpriteFrames:dRunAnimFrames delay:0.2f];
    
    self.dogRunAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:dRunAnim]];
    
    // LOAD CLIMB ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ClimbAnims.plist"];
    
    CCSpriteBatchNode *spriteSheetClimb = [CCSpriteBatchNode batchNodeWithFile:@"ClimbAnims.png"];
    [self addChild:spriteSheetClimb];
    
    NSMutableArray *climbAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 2; i++) {
        [climbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerClimb%d.png",i]]];
        [climbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DuelistPlayerHang.png"]];
    }
    
    CCAnimation *climbAnim = [CCAnimation
                             animationWithSpriteFrames:climbAnimFrames delay:0.2f];
    
    self.climbAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:climbAnim]];
    
    // LOAD JUMP AND ATTACK ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DuelJumpAttack.plist"];
    
    CCSpriteBatchNode *spriteSheetJump = [CCSpriteBatchNode batchNodeWithFile:@"DuelJumpAttack.png"];
    [self addChild:spriteSheetJump];
    
    NSMutableArray *jumpAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 2; i++) {
        [jumpAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerJump%d.png",i]]];
    }
    
    CCAnimation *jumpAnim = [CCAnimation
                             animationWithSpriteFrames:jumpAnimFrames delay:0.2f];
    
    self.jumpAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:jumpAnim] times:1];
    
    NSMutableArray *attackAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 2; i++) {
        [attackAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistPlayerAttack%d.png",i]]];
    }
    
    CCAnimation *attackAnim = [CCAnimation
                             animationWithSpriteFrames:attackAnimFrames delay:0.15f];
    
    self.attackAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:attackAnim] times:1];
    
    // LOAD DIE ANIM
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DuelistDieAni.plist"];
    
    CCSpriteBatchNode *spriteSheetDie = [CCSpriteBatchNode batchNodeWithFile:@"DuelistDieAni.png"];
    [self addChild:spriteSheetDie];
    
    NSMutableArray *dieAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= 9; i++) {
        [dieAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DuelistDie%d.png",i]]];
    }
    
    CCAnimation *dieAnim = [CCAnimation
                             animationWithSpriteFrames:dieAnimFrames delay:0.12f];
    
    self.dieAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:dieAnim] times:1];
    
}

- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    float x = floor(position.x / (map.tileSize.width/scaleF));
    float levelHeightInPixels = map.mapSize.height * (map.tileSize.height/scaleF);
    float y = floor((levelHeightInPixels - position.y) / (map.tileSize.height/scaleF));
    return ccp(x, y);
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords
{
    float levelHeightInPixels = map.mapSize.height * (map.tileSize.height/scaleF);
    CGPoint origin = ccp(tileCoords.x * (map.tileSize.width/scaleF), levelHeightInPixels - ((tileCoords.y + 1) * (map.tileSize.height/scaleF)));
    return CGRectMake(origin.x, origin.y, (map.tileSize.width/scaleF), (map.tileSize.height/scaleF));
}

-(NSArray *)getSurroundingTilesAtPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer {
    
    CGPoint plPos = [self tileCoordForPosition:position]; //1
    
    NSMutableArray *gids = [NSMutableArray array]; //2
    
    for (int i = 0; i < 9; i++) { //3
        int c = i % 3;
        int r = (int)(i / 3);
        CGPoint tilePos = ccp(plPos.x + (c - 1), plPos.y + (r - 1));
        
        int tgid = [layer tileGIDAt:tilePos]; //4
        
        CGRect tileRect = [self tileRectFromTileCoords:tilePos]; //5
        
        NSDictionary *tileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:tgid], @"gid",
                                  [NSNumber numberWithFloat:tileRect.origin.x], @"x",
                                  [NSNumber numberWithFloat:tileRect.origin.y], @"y",
                                  [NSValue valueWithCGPoint:tilePos],@"tilePos",
                                  nil];
        [gids addObject:tileDict]; //6
        
    }
    
    [gids removeObjectAtIndex:4];
    [gids insertObject:[gids objectAtIndex:2] atIndex:6];
    [gids removeObjectAtIndex:2];
    [gids exchangeObjectAtIndex:4 withObjectAtIndex:6];
    [gids exchangeObjectAtIndex:0 withObjectAtIndex:4]; //7
    
    return (NSArray *)gids;
}

-(void)checkForAndResolveCollisions:(Player *)p {
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.position forLayer:walls ];
    
    p.onGround = NO;
    
    for (NSDictionary *dic in tiles) {
        CGRect pRect = [p collisionBoundingBox];
        
        int gid = [[dic objectForKey:@"gid"] intValue];
        
        if (gid) {
            CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], (map.tileSize.width/scaleF), (map.tileSize.height/scaleF));
            if (CGRectIntersectsRect(pRect, tileRect)) {
                CGRect intersection = CGRectIntersection(pRect, tileRect);
                
                int tileIndx = [tiles indexOfObject:dic];
                
                if (tileIndx == 0) {
                    //tile is directly below player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                    if ( p.doneJumping == NO ) { [self playerLanded]; }
                    p.onGround = YES;
                    p.detachedWall = NO;
                } else if (tileIndx == 1) {
                    //tile is directly above player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y - intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                } else if (tileIndx == 2) {
                    //tile is left of player
                    p.desiredPosition = ccp(p.desiredPosition.x + intersection.size.width, p.desiredPosition.y);
                } else if (tileIndx == 3) {
                    //tile is right of player
                    p.desiredPosition = ccp(p.desiredPosition.x - intersection.size.width, p.desiredPosition.y);
                } else {
                    if (intersection.size.width > intersection.size.height) {
                        //tile is diagonal, but resolving collision vertically
                        p.velocity = ccp(p.velocity.x, 0.0);
                        float intersectionHeight;
                        if (tileIndx > 5) {
                            intersectionHeight = intersection.size.height;
                            if ( p.doneJumping == NO ) { [self playerLanded]; }
                            p.onGround = YES;
                            p.detachedWall = NO;
                        } else {
                            intersectionHeight = -intersection.size.height;
                        }
                        //p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + intersection.size.height );
                        p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + intersectionHeight );
                    } else {
                        //tile is diagonal, but resolving horizontally
                        float resolutionWidth;
                        if (tileIndx == 6 || tileIndx == 4) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        p.desiredPosition = ccp(p.desiredPosition.x + resolutionWidth, p.desiredPosition.y);
                    }
                }
            }
        }
    }
    p.position = p.desiredPosition;
}

-(void)handleHazardCollisions:(Player *)p {
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.position forLayer:hazards];
    for (NSDictionary *dic in tiles) {
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], (map.tileSize.width/scaleF), (map.tileSize.height/scaleF));
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            [self gameOver:0];
        }
    }
}

-(void)handleFalseWallCollisions:(Player *)p {
    inSmallSpace = NO;
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.position forLayer:falseWalls];
    for (NSDictionary *dic in tiles) {
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], (map.tileSize.width/scaleF), (map.tileSize.height/scaleF));
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            inSmallSpace = YES;
        }
    }
}

-(void)handleCollectables:(Player *)p {
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.position forLayer:pickups];
    for (NSDictionary *dic in tiles) {
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], (map.tileSize.width/scaleF), (map.tileSize.height/scaleF));
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            // REMOVE PICKUP FROM SCREEN
            NSValue *val = [dic objectForKey:@"tilePos"];
            //CCSprite *supply = [pickups tileAt:[val CGPointValue]];
            [pickups removeTileAt:[val CGPointValue]];
            //[gameStats incSupplies:supply];
            [player incHp];
            [gameStats updateBar:player.hp];
        }
    }
}

-(void)addProjectile:(CGPoint)_origin Target:(CGPoint)_target {
    CCSprite *projectile = [CCSprite spriteWithFile:@"SpitterProjectile.png"];
    projectile.position = _origin;
    projectile.tag = 0;
    [map addChild:projectile z:40];
    [projectiles addObject:projectile];
    [projectile runAction:[CCSequence actions:
                       [CCMoveTo actionWithDuration:2.0 position:_target],
                           [CCCallFuncO actionWithTarget:self selector:@selector(markAsRemoved:) object:projectile],
                           [CCCallFuncND actionWithTarget:projectile
                                                 selector:@selector(removeFromParentAndCleanup:)
                                                     data:(void*)NO], nil]];
}
-(void)addKnivesAttack:(CGPoint)_origin Direction:(int)_dir {
    if ( arc4random() %2+1 == 1 ) {
        for ( int i = 0; i < 560; i+=140 ) {
        
            CCSprite *projectile = [CCSprite spriteWithFile:@"BossKnife.png"];
            CGPoint dest = ccp(_origin.x+(500*_dir)-(i*_dir), _origin.y+i);
            projectile.position = _origin;
            projectile.tag = 0;
            projectile.rotation = (atan2f(dest.x-_origin.x, dest.y-_origin.y)*57.3)-90;
            //projectile.scaleX = _dir;
            [map addChild:projectile z:40];
            [projectiles addObject:projectile];
            [projectile runAction:[CCSequence actions:
                                   [CCMoveTo actionWithDuration:1.8 position:dest],
                                   [CCCallFuncO actionWithTarget:self selector:@selector(markAsRemoved:) object:projectile],
                                   [CCCallFuncND actionWithTarget:projectile
                                                         selector:@selector(removeFromParentAndCleanup:)
                                                             data:(void*)NO], nil]];
        }
    }
    else {
        for ( int i = -20; i < 50; i+=15 ) {
            
            CCSprite *projectile = [CCSprite spriteWithFile:@"BossKnife.png"];
            projectile.position = ccp(_origin.x, _origin.y+i);
            projectile.tag = 0;
            projectile.scaleX = _dir;
            [map addChild:projectile z:40];
            [projectiles addObject:projectile];
            [projectile runAction:[CCSequence actions:
                                   [CCMoveTo actionWithDuration:2.0 position:ccp(_origin.x+(500*_dir), projectile.position.y)],
                                   [CCCallFuncO actionWithTarget:self selector:@selector(markAsRemoved:) object:projectile],
                                   [CCCallFuncND actionWithTarget:projectile
                                                         selector:@selector(removeFromParentAndCleanup:)
                                                             data:(void*)NO], nil]];
        }
    }
    [[SimpleAudioEngine sharedEngine] playEffect:@"swordSwing.mp3"];
}
-(void)addSingleSlimeAttack:(CGPoint)_origin Direction:(int)_dir {
    CCSprite *projectile = [CCSprite spriteWithFile:@"BossSlime.png"];
    float distX = ((player.position.x-_origin.x)*1.5), distY = ((player.position.y-_origin.y)*1.5);
    CGPoint dest = ccp(_origin.x+(arc4random()%60+(distX-30)), _origin.y+(arc4random()%60+(distY-30)));
    projectile.position = _origin;
    projectile.tag = 0;
    projectile.rotation = (atan2f(dest.x-_origin.x, dest.y-_origin.y)*57.3)-90;
    [map addChild:projectile z:40];
    [projectiles addObject:projectile];
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:ccpDistance(_origin, dest)/200.0f position:dest],
                           [CCCallFuncO actionWithTarget:self selector:@selector(markAsRemoved:) object:projectile],
                           [CCCallFuncND actionWithTarget:projectile
                                                 selector:@selector(removeFromParentAndCleanup:)
                                                     data:(void*)NO], nil]];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Splasher.m4a"];
}
-(void)addBirdAttack:(NSObject*)_bird Direction:(int)_dir {
    CCSprite *projectile = [CCSprite spriteWithFile:@"birdAttack.png"];
    Bird *b = (Bird*)_bird;
    CGPoint _origin = b.position;
    float distX = ((player.position.x-_origin.x)*1.5), distY = ((player.position.y-_origin.y)*1.5);
    CGPoint dest = ccp(_origin.x+(arc4random()%60+(distX-30)), _origin.y+(arc4random()%60+(distY-30)));
    projectile.position = _origin;
    projectile.tag = 10;
    projectile.scaleX = _dir;
    [map addChild:projectile z:40];
    [b removeFromParentAndCleanup:NO];
    b.tag = -1;
    [projectiles addObject:projectile];
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:ccpDistance(_origin, dest)/240.0f position:dest],
                           [CCCallFuncO actionWithTarget:self selector:@selector(markAsRemoved:) object:projectile],
                           [CCCallFuncND actionWithTarget:projectile
                                                 selector:@selector(removeFromParentAndCleanup:)
                                                     data:(void*)NO], nil]];
}
- (void) markAsRemoved:(CCSprite*)_projectile {
    _projectile.tag = 1;
}

-(void)gameOver:(BOOL)won {
	gameOver = YES;
	NSString *gameText;
    [[GameStateManager sharedInstance] setHp:5];
    
    [player stopAllActions];
    [player runAction:[self.dieAction copy]];
    
	if (won) {
		gameText = @"You Found All The Supplies!";
	} else {
		gameText = @"You have Died!";
	}
    
    CCLabelTTF *diedLabel = [[CCLabelTTF alloc] initWithString:gameText fontName:@"Marker Felt" fontSize:40];
    diedLabel.position = ccp(240, 200);
    CCMoveBy *slideIn = [[CCMoveBy alloc] initWithDuration:1.0 position:ccp(0, 250)];
    CCMenuItemImage *replay = [[CCMenuItemImage alloc] initWithNormalImage:@"replay.png" selectedImage:@"replay.png" disabledImage:@"replay.png" block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    }];
    
    NSArray *menuItems = [NSArray arrayWithObject:replay];
    CCMenu *menu = [[CCMenu alloc] initWithArray:menuItems];
    menu.position = ccp(240, -100);
    
    [self addChild:menu];
    [self addChild:diedLabel];
    
    [menu runAction:slideIn];
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (map.mapSize.width * (map.tileSize.width/scaleF))
            - winSize.width / 2);
    y = MIN(y, (map.mapSize.height * (map.tileSize.height/scaleF))
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    map.position = viewPoint;
    bgIm.position = ccp(map.position.x/3.0f, map.position.y/3.0f);
}

- (void) changeBGColor {
    /*float newcolor = blueSky.color.b + (float)(arc4random()%10-10);
     if ( newcolor > 255.0 ) newcolor = 255.0;
     else if ( newcolor < 0 ) newcolor = 0;
     [blueSky setColor:ccc3(100, 100, newcolor)];*/
}

- (void) playerBecameStatic {
    [player stopAllActions];
    if ( player.climbing ) {
        if ( player.forwardMarch == YES || player.backwardJaunt == YES ) {
            [player runAction:[self.climbAction copy]];
        }
        else {
            [player setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DuelistPlayerHang.png"]];
        }
    }
    else if ( !player.isDog ) {
        //[player setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DuelistPlayer.png"]];
        [player runAction:[self.staticAction copy]];
    }
    else {
        [player setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"DuelistPlayerDog.png" rect:CGRectMake(0, 0, 22, 15)]];
    }
}
- (void) playerLanded {
    if ( !player.attacking ) {
        if ( (player.forwardMarch || player.backwardJaunt) && !player.isDog ) {
            // move animation
            [player stopAllActions];
            [self playerStartedMoving];
        }
        else {
            // landing animation
            [self playerBecameStatic];
        }
    }
    player.doneJumping = YES;
}
- (void) playerStartedMoving {
    if ( player.isDog ) {
        [player runAction:[self.dogRunAction copy]];
    }
    else {
        [player runAction:[self.walkAction copy]];
    }
}
- (void) resetPlayerAttack {
    player.attacking = NO;
    
    if ( player.forwardMarch || player.backwardJaunt ) {
        [player stopAllActions];
        [self playerStartedMoving];
    }
    else {
        [self playerBecameStatic];
    }
    //player.position = ccp(player.position.x-(10*player.scaleX), player.position.y);
}

- (void) checkEnemyVision {
    NSMutableArray *done = [NSMutableArray new];
    for ( Spitter *s in enemies ) {
        if ( CGRectIntersectsRect([s visionBoundingBox], [player boundingBox]) ) {
            [s playerInRange:[player boundingBox]];
        }
        else {
            if ( s.attacking == YES ) {
                s.attacking = NO;
                [s unschedule:@selector(attack)];
            }
        }
        if ( s.tag == -1) {
            [done addObject:s];
        }
    }
    [enemies removeObjectsInArray:done];
}

- (void) checkDoorTouches {
    if ( resetDoors == YES ) {
        resetDoors = NO;
        for ( Door *d in doors ) { [map removeChild:d cleanup:YES]; }
        [doors removeAllObjects];
        doors = [NSMutableArray new];
        CCTMXObjectGroup *objectGroup = [map objectGroupNamed:@"doors"];
        
        for ( NSDictionary *doDic in [objectGroup objects] ) {
            int x = [doDic[@"x"] integerValue];
            int y = [doDic[@"y"] integerValue];
            int doLevel = [doDic[@"level"] integerValue];
            int doSpawn = [doDic[@"spawn"] integerValue];
            NSString *fName = @"transDoor.png";
            if ( [doDic objectForKey:@"special"] ) { fName = @"transDoorBoss.png"; }
            if ( [doDic objectForKey:@"boss"] ) {
                if ( [[GameStateManager sharedInstance] haveBeatenBoss:[[doDic objectForKey:@"boss"] intValue]] == YES ) {
                    Door *door = [[Door alloc] initWithFile:fName Level:doLevel Spawn:doSpawn];
                    door.position = ccp(x/scaleF, y/scaleF);
                    [map addChild:door z:45];
                    [doors addObject:door];
                }
            }
            else {
                Door *door = [[Door alloc] initWithFile:fName Level:doLevel Spawn:doSpawn];
                door.position = ccp(x/scaleF, y/scaleF);
                [map addChild:door z:45];
                [doors addObject:door];
            }
        }
    }
    else {
        bool touched = NO;
        for ( Door *d in doors ) {
            if ( CGRectIntersectsRect(d.boundingBox, [player doorBoundingBox]) ) {
                touched = YES;
                [[GameStateManager sharedInstance] setLevel:d.level Spawn:d.spawnPoint Hp:player.hp];
            }
        }
        if ( touched == YES ) {
            gameOver = YES;
            //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
            if ( [nextAudio isEqualToString:@"AngryMod.mp3"] ) {
                [self crossFadeBGM:@"Delerium.mp3"];
            }
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
        }
    }
}

- (void) checkClimbing {
    bool touched = NO;
    for ( CCSprite *c in climbTiles ) {
        CGRect collisionBox = CGRectMake(c.boundingBox.origin.x, c.boundingBox.origin.y+(c.boundingBox.size.height-8), c.boundingBox.size.width, 10);
        if ( CGRectIntersectsRect(collisionBox, [player climbBoundingBox]) ) {
            touched = YES;
            if ( !player.climbing && !player.detachedWall ) {
                player.climbing = YES;
                [self playerBecameStatic];
            }
        }
    }
    if ( touched == NO && player.climbing ) {
        player.climbing = NO;
        player.detachedWall = YES;
    }
}

- (void) checkRelicTouches {
    NSMutableArray *done = [NSMutableArray new];
    for ( Relic *r in relics ) {
        if ( CGRectIntersectsRect(r.boundingBox, [player doorBoundingBox]) ) {
            [done addObject:r];
            [[GameStateManager sharedInstance] foundRelic:r.name];
            [r collected];
            relicFound = [[RelicFoundView alloc] initWithRelic:r.name Description:[[GameStateManager sharedInstance] getRelicDesc:r.name] Game:self];
            [self addChild:relicFound z:100];
            player.canDoubleJump = [[GameStateManager sharedInstance] haveFoundThisRelic:@"doubleJump"];
            if ( [r.name isEqualToString:@"dogAmulet"] ) {
                actionX = [CCSprite spriteWithFile:@"actionButtonX.png"];
                actionX.position = ccp(310, left.position.y);
                [self addChild:actionX];
                player.hasDogAmulet = YES;
            }
        }
    }
    [relics removeObjectsInArray:done];
}

- (void) checkProjectileCollisions {
    NSMutableArray *done = [NSMutableArray new];
    for ( CCSprite *proj in projectiles ) {
        if ( proj.tag == 10 && player.attacking == YES && CGRectIntersectsRect([player swordBoundingBox], proj.boundingBox) ) {
            [proj stopAllActions];
            [self showFeatherCloud:proj.position.x y:proj.position.y];
            proj.tag = 1;
            [proj removeFromParentAndCleanup:NO];
        }
        else if ( CGRectIntersectsRect([player projectileBoundingBox], proj.boundingBox) && player.hurting == NO ) {
            //[self gameOver:0];
            [player hit];
            [gameStats updateBar:player.hp];
        }
        if ( proj.tag == 1 ) {
            [done addObject:proj];
        }
    }
    [projectiles removeObjectsInArray:done];
    if ( player.hp < 0 ) {
        [self gameOver:0];
    }
}

- (void) checkPlayerAttack {
    CGRect swordArea = [player swordBoundingBox];
    NSMutableArray *done = [NSMutableArray new];
    for ( Spitter *s in enemies ) {
        if ( CGRectIntersectsRect(s.boundingBox, swordArea) ) {
            s.hp--;
            if ( s.hp <= 0 ) {
                [done addObject:s];
                [s die:player.scaleX];
            }
            else {
                [self showSmoke:s.position.x y:s.position.y];
                [s hit:player.position.x];
            }
        }
    }
    [enemies removeObjectsInArray:done];
}

- (void) relicVisible {
    relicViewActive = YES;
}

- (void) bossToppled {
    [[SimpleAudioEngine sharedEngine] playEffect:@"bossDeath.mp3"];
    [[GameStateManager sharedInstance] incBossKills];
    resetDoors = YES;
    [self crossFadeBGM:@"Delerium.mp3"];
}

-(void) showSmoke: (float) x y:(float) y {
    
    CCParticleSystem *emitter;
    emitter = [[CCParticleSmoke alloc] init];
    
    //emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"confetti.png"];
    
    emitter.duration = 1.2;
    emitter.life = 1.5;
    emitter.lifeVar = 0.3;
    //emitter.gravity = ccp(player.position.x, 90);
    //emitter.angle = 90;
    //emitter.angleVar = 360;
    //emitter.speed = 160;
    //emitter.speedVar = 20;
    
    ccColor4F endColor = {100.0f, 100.0f, 100.0f, 1.0f};
    emitter.endColor = endColor;
    
    //emitter.totalParticles = 250;
    //emitter.emissionRate = emitter.totalParticles/emitter.life;
    
    //emitter.posVar = ccp(x + 20, y - 20);
    emitter.position = ccp(x,y-10);
    emitter.positionType = kCCPositionTypeRelative;
    
    emitter.blendAdditive = NO;
    
    [map addChild: emitter z:100];
    emitter.autoRemoveOnFinish = YES;
    
    // We call the doWon function when the particle system completes
    // so that we can take the player to the You Won screen.
    //[self scheduleOnce:@selector(doWon) delay:3];
}
-(void)showFeatherCloud: (float) x y:(float) y {
    CCParticleSystem *emitter;
    emitter = [[CCParticleExplosion alloc] init];
    
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"feather.png"];
    
    emitter.duration = 0.2;
    emitter.life = 1.5;
    emitter.lifeVar = 0.3;
    emitter.emissionRate = 80;
    emitter.gravity = ccp(0, -120);
    
    ccColor4F statColor = {100.0f, 100.0f, 100.0f, 1.0f};
    ccColor4F varColor = {0.0f, 0.0f, 0.0f, 1.0f};
    emitter.startColor = statColor;
    emitter.startColorVar = varColor;
    emitter.endColor = statColor;
    emitter.endColorVar = varColor;
    
    emitter.startSizeVar = 5.0f;
    emitter.position = ccp(x,y-10);
    emitter.positionType = kCCPositionTypeRelative;
    
    emitter.blendAdditive = NO;
    
    [map addChild: emitter z:100];
    emitter.autoRemoveOnFinish = YES;
    
}
-(void)showBossDeathParticles:(CGPoint)_bossLocal Layer:(int)_zPos {
    CCParticleSystem *emitter;
    emitter = [[CCParticleSun alloc] init];
    
    emitter.duration = 1.2;
    emitter.life = 1.5;
    emitter.lifeVar = 0.3;
    
    // Default start colour is .76 .25 .12 1 (orange)
    ccColor4F startColor = {50.0f, 200.0f, 50.0f, 1.0f};
    emitter.startColor = startColor;
    
    emitter.position = ccp(_bossLocal.x,_bossLocal.y-10);
    emitter.positionType = kCCPositionTypeRelative;
    
    [map addChild: emitter z:_zPos-1];
    emitter.autoRemoveOnFinish = YES;
}

-(void)crossFadeBGM:(NSString*)_newMusic {
    [self unschedule:@selector(fadeUpdate)];
    nextAudio = _newMusic;
    fadingOut = YES;
    [self schedule:@selector(fadeUpdate) interval:0.2];
}
-(void)fadeUpdate {
    float audioVolume = [[SimpleAudioEngine sharedEngine] backgroundMusicVolume];
    if ( fadingOut ) {
        audioVolume -= 0.1f;
        if ( audioVolume <= 0.0f ) {
            fadingOut = NO;
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:nextAudio loop:YES];
        }
    }
    else {
        audioVolume += 0.1f;
        if ( audioVolume == 1.0f ) {
            [self unschedule:@selector(fadeUpdate)];
        }
    }
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:audioVolume];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ( relicViewActive ) {
        [relicFound dismissed];
        relicViewActive = NO;
    }
    else if ( !gameOver ) {
        for (UITouch *t in touches) {
            CGPoint touchLocation = [self convertTouchToNodeSpace:t];
            
            /*if (touchLocation.x > 240) {
             player.mightAsWellJump = YES;
             } else {
             player.forwardMarch = YES;
             }*/
            if ( player.attacking == NO ) {
                if ( CGRectContainsPoint([action boundingBox], touchLocation) && !player.isDog ) {
                    if ( player.climbing ) {
                        player.climbing = NO;
                        player.detachedWall = YES;
                        [self playerBecameStatic];
                    }
                    else {
                        if ( player.mightAsWellJump == NO ) {
                            if ( !player.attacking ) {
                                [player stopAllActions];
                                [player runAction:[self.jumpAction copy]];
                            }
                        }
                        player.extraJumps++;
                        player.mightAsWellJump = YES;
                    }
                    break;
                }
                else if ( CGRectContainsPoint([right boundingBox], touchLocation) ) {
                    player.backwardJaunt = NO;
                    player.forwardMarch = YES;
                    player.scaleX = 1.f;
                    if ( player.doneJumping == YES ) {
                        [player stopAllActions];
                        [self playerStartedMoving];
                    }
                    else if ( player.climbing ) {
                        [player stopAllActions];
                        [player runAction:[self.climbAction copy]];
                    }
                    break;
                }
                else if ( CGRectContainsPoint([left boundingBox], touchLocation) ) {
                    player.forwardMarch = NO;
                    player.backwardJaunt = YES;
                    player.scaleX = -1.f;
                    if ( player.doneJumping == YES ) {
                        [player stopAllActions];
                        [self playerStartedMoving];
                    }
                    else if ( player.climbing ) {
                        [player stopAllActions];
                        [player runAction:[self.climbAction copy]];
                    }
                    break;
                }
            }
            
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
     
     CGPoint touchLocation = [self convertTouchToNodeSpace:t];
     
     //get previous touch and convert it to node space
     CGPoint previousTouchLocation = [t previousLocationInView:[t view]];
     CGSize screenSize = [[CCDirector sharedDirector] winSize];
     previousTouchLocation = ccp(previousTouchLocation.x, screenSize.height - previousTouchLocation.y);
     
        if ( CGRectContainsPoint([right boundingBox], previousTouchLocation) && !CGRectContainsPoint([right boundingBox], touchLocation) ) {
            player.forwardMarch = NO;
            if ( !player.attacking ) {
                [player stopAllActions];
                [self playerBecameStatic];
            }
        }
        else if ( CGRectContainsPoint([left boundingBox], previousTouchLocation) && !CGRectContainsPoint([left boundingBox], touchLocation) ) {
            player.backwardJaunt = NO;
            if ( !player.attacking ) {
                [player stopAllActions];
                [self playerBecameStatic];
            }
        }
     }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ( !gameOver ) {
    
    for (UITouch *t in touches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        /*if (touchLocation.x < 240) {
         player.forwardMarch = NO;
         } else {
         player.mightAsWellJump = NO;
         }*/
        if ( CGRectContainsPoint([action boundingBox], touchLocation) ) {
            player.mightAsWellJump = NO;
        }
        else if ( CGRectContainsPoint([actionB boundingBox], touchLocation) && !player.isDog ) {
            if ( player.attacking == NO /*&& player.doneJumping == YES*/ ) {
                player.attacking = YES;
                [[SimpleAudioEngine sharedEngine] playEffect:@"swordSwing.mp3"];
                //[player stopAllActions];
                //player.forwardMarch = NO;
                //player.backwardJaunt = NO;
                //[player setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"DuelistPlayerAttack.png" rect:CGRectMake(0, 0, 50, 50)]];
                [player stopAllActions];
                [player runAction:[self.attackAction copy]];
                //player.position = ccp(player.position.x+(10*player.scaleX), player.position.y);
                [self performSelector:@selector(resetPlayerAttack) withObject:nil afterDelay:0.5];
            }
        }
        else if ( CGRectContainsPoint([right boundingBox], touchLocation) ) {
            player.forwardMarch = NO;
            if ( !player.attacking ) {
                [player stopAllActions];
                [self playerBecameStatic];
            }
        }
        else if ( CGRectContainsPoint([left boundingBox], touchLocation) ) {
            player.backwardJaunt = NO;
            if ( !player.attacking ) {
                [player stopAllActions];
                [self playerBecameStatic];
            }
        }
        else if ( CGRectContainsPoint([actionX boundingBox], touchLocation) && player.doneJumping && !inSmallSpace ) {
            [player stopAllActions];
            [self showSmoke:player.position.x y:player.position.y];
            [player transmute];
            if ( player.forwardMarch || player.backwardJaunt ) {
                [self playerStartedMoving];
            }
        }
    }
        
    }
}

-(void)update:(ccTime)dt
{
    if (gameOver) {
        return;
    }
    [player update:dt];
    [self handleHazardCollisions:player];
    [self handleCollectables:player];
    [self handleFalseWallCollisions:player];
    [self checkForAndResolveCollisions:player];
    [self checkEnemyVision];
    [self checkProjectileCollisions];
    if ( player.attacking == YES ) {
        [self checkPlayerAttack];
    }
    [self checkDoorTouches];
    [self checkRelicTouches];
    if ( player.hasClimbSpikes ) { [self checkClimbing]; }
    [self setViewpointCenter:player.position];
    //}
}

@end
