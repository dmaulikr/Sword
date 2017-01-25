//
//  RelicFoundView.h
//  Duelist
//
//  Created by freddy on 17/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@class HelloWorldLayer;

@interface RelicFoundView : CCNode {
    
}

@property (nonatomic,weak) HelloWorldLayer *theGame;

- (id) initWithRelic:(NSString*)_relicName Description:(NSString*)_desc Game:(HelloWorldLayer*)_theGame;

- (void) dismissed;

@end
