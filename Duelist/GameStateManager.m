//
//  GameStateManager.m
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright (c) 2013 Freddie. All rights reserved.
//

#import "GameStateManager.h"

@implementation GameStateManager

static GameStateManager *sharedManager = nil;
+ (GameStateManager *) sharedInstance {
    if (!sharedManager) {
        sharedManager = [[GameStateManager alloc] init];
    }
    return sharedManager;
}

- (id) init {
    if ( self = [super init] ) {
        [self loadData];
        [self setLevel:[[[gameData objectForKey:@"State"] objectForKey:@"Level"] intValue] Spawn:[[[gameData objectForKey:@"State"] objectForKey:@"Spawn"] intValue] Hp:[[[gameData objectForKey:@"State"] objectForKey:@"HP"] intValue]];
    }
    return self;
}

- (void) setLevel:(int)_level Spawn:(int)_spawn Hp:(int)_hp {
    level = _level;
    spawn = _spawn;
    hp = _hp;
    [[gameData objectForKey:@"State"] setValue:[NSNumber numberWithInt:level] forKey:@"Level"];
    [[gameData objectForKey:@"State"] setValue:[NSNumber numberWithInt:spawn] forKey:@"Spawn"];
    [[gameData objectForKey:@"State"] setValue:[NSNumber numberWithInt:hp] forKey:@"HP"];
    [self updateFile:@"GameData.plist" withDic:gameData];
}
- (void) setHp:(int)_hp {
    hp = _hp;
    [[gameData objectForKey:@"State"] setValue:[NSNumber numberWithInt:hp] forKey:@"HP"];
    [self updateFile:@"GameData.plist" withDic:gameData];
}

- (void) loadData {
    [self CheckFileExists:@"GameData.plist"];
    gameData = [[NSMutableDictionary alloc] init];
    gameData = [self GetContentsOfFileInDic:@"GameData.plist"];
}

- (void) foundRelic:(NSString *)_relName {
    if ( !gameData ) {
        [self loadData];
    }
    [[[gameData objectForKey:@"Relics"] objectForKey:_relName] setValue:[NSNumber numberWithBool:YES] forKey:@"Unlocked"];
    [self updateFile:@"GameData.plist" withDic:gameData];
}

- (void) resetGame {
    [self CopyFile:@"GameData.plist"];
    [self loadData];
    [self setLevel:1 Spawn:1 Hp:5];
}

- (void) incBossKills {
    if ( !gameData ) {
        [self loadData];
    }
    
    int boss = [[[gameData objectForKey:@"State"] objectForKey:@"Boss"] intValue];
    boss++;
    [[gameData objectForKey:@"State"] setValue:[NSNumber numberWithInt:boss] forKey:@"Boss"];
    [self updateFile:@"GameData.plist" withDic:gameData];
}

- (int) getCurrentLevel {
    return level;
}
- (int) getSpawnPoint {
    return spawn;
}
- (int) getHp {
    return hp;
}

- (BOOL) haveFoundThisRelic:(NSString *)_relic {
    if ( !gameData ) {
        [self loadData];
    }
    return [[[[gameData objectForKey:@"Relics"] objectForKey:_relic] objectForKey:@"Unlocked"] boolValue];
}

- (BOOL) haveBeatenBoss:(int)_bossNumber {
    if ( !gameData ) {
        [self loadData];
    }
    
    if ( [[[gameData objectForKey:@"State"] objectForKey:@"Boss"] intValue] >= _bossNumber ) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*) getRelicDesc:(NSString *)_relic {
    if ( !gameData ) {
        [self loadData];
    }
    return [[[gameData objectForKey:@"Relics"] objectForKey:_relic] objectForKey:@"Description"];
}

- (void) CheckFileExists:(NSString*)_filePath {
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [applicationDocumentsDir stringByAppendingPathComponent:_filePath];
    
    BOOL isFileAvailable = [[NSFileManager defaultManager] fileExistsAtPath:filesPath];
    if ( !isFileAvailable ){
        [self CopyFile:_filePath];
    }
}
- (void) CopyFile:(NSString *)_filePath {
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [applicationDocumentsDir stringByAppendingPathComponent:_filePath];
    NSString *primPath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [primPath stringByAppendingPathComponent:_filePath];
    NSMutableDictionary *charactersDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    [charactersDict writeToFile:filesPath atomically:YES];
}
- (NSMutableDictionary*) GetContentsOfFileInDic:(NSString *)_fileName {
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [applicationDocumentsDir stringByAppendingPathComponent:_fileName];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    
    return data;
}
- (void)updateFile:(NSString*)_file withDic:(NSMutableDictionary*)_dataDic {
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [applicationDocumentsDir stringByAppendingPathComponent:_file];
    
    [_dataDic writeToFile:filesPath atomically:YES];
}

@end
