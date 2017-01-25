//
//  GameStateManager.h
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright (c) 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStateManager : NSObject {
    int level, spawn, hp;
    NSMutableDictionary *gameData;
}

+ (GameStateManager *)sharedInstance;

- (void) setLevel:(int)_level Spawn:(int)_spawn Hp:(int)_hp;
- (void) setHp:(int)_hp;
- (void) loadData;
- (void) foundRelic:(NSString*)_relName;
- (void) resetGame;
- (void) incBossKills;

- (int) getCurrentLevel;
- (int) getSpawnPoint;
- (int) getHp;

- (BOOL) haveFoundThisRelic:(NSString*)_relic;
- (BOOL) haveBeatenBoss:(int)_bossNumber;
- (NSString*) getRelicDesc:(NSString*)_relic;

@end
