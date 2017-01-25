//
//  Door.h
//  Duelist
//
//  Created by freddy on 13/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Door : CCSprite {
    
}

- (id) initWithFile:(NSString *)filename Level:(int)_level Spawn:(int)_sPoint;

@property (nonatomic) int level, spawnPoint;

@end
