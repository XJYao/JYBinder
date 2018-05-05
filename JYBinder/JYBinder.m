//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"

@implementation JYBinder

+ (void)bindToSingleWay:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    [JYBinderGenerator bindToSingleWay:leadingTerminal followingTerminal:followingTerminal];
}

+ (void)bindToTwoWay:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator bindToTwoWay:terminal otherTerminal:otherTerminal];
}

+ (void)unbindWithTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator unbindWithTerminal:terminal otherTerminal:otherTerminal];
}

@end
