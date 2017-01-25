//
//  Relic.h
//  Duelist
//
//  Created by freddy on 16/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Relic : CCSprite {
    
}

- (id) initWithFile:(NSString *)filename Name:(NSString*)_name;

@property (nonatomic) NSString *name;

- (void) collected;

@end
