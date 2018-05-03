//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"

@implementation JYBinder

+ (void)bindToSingleWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    [JYBinderGenerator bindToSingleWayChannel:leadingTerminal followingTerminal:followingTerminal];
}

+ (void)bindToTwoWayChannel:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator bindToTwoWayChannel:terminal otherTerminal:otherTerminal];
}

+ (void)unbindWithTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator unbindWithTerminal:terminal otherTerminal:otherTerminal];
}

@end
