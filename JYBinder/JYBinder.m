//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"

@implementation JYBinder

+ (void)bindToSingleWayWithLeading:(JYBinderTerminal *)leadingTerminal following:(JYBinderTerminal *)followingTerminal {
    [JYBinderGenerator bindToSingleWayWithLeading:leadingTerminal following:followingTerminal];
}

+ (void)bindToTwoWayWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator bindToTwoWayWithOneTerminal:terminal otherTerminal:otherTerminal];
}

+ (void)unbindWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [JYBinderGenerator unbindWithOneTerminal:terminal otherTerminal:otherTerminal];
}

+ (void)unbindWithTarget1:(NSObject *__weak)target1 keyPath1:(NSString *)keyPath1 target2:(NSObject *__weak)target2 keyPath2:(NSString *)keyPath2 {
    [JYBinderGenerator unbindWithTarget1:target1 keyPath1:keyPath1 target2:target2 keyPath2:keyPath2];
}

@end
