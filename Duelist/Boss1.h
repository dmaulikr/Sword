//
//  Boss1.h
//  Duelist
//
//  Created by freddy on 19/09/2013.
//  Copyright 2013 Freddie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Spitter.h"

@interface Boss1 : Spitter {
    
}

- (id) initWithFile:(HelloWorldLayer *)_game BoundX:(float)_minX BoundX2:(float)_maxX;

@end
