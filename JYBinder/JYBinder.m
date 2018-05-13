//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"
#import "JYBinderChannelManager.h"
#import "JYBinderChannel.h"
#import "JYBinderUtil.h"

@interface JYBinder ()

@property (nonatomic, weak) NSObject *target;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) BOOL isTwoWay;

@end

@implementation JYBinder

+ (void)bindToSingleWayWithLeading:(JYBinderTerminal *)leadingTerminal following:(JYBinderTerminal *)followingTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal]];
}

+ (void)bindToTwoWayWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initTwoWayWithOneTerminal:terminal otherTerminal:otherTerminal]];
}

+ (void)unbindWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] removeChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:terminal followingTerminal:otherTerminal]];
}

+ (void)unbindWithTarget1:(NSObject *__weak)target1 keyPath1:(NSString *)keyPath1 target2:(NSObject *__weak)target2 keyPath2:(NSString *)keyPath2 {
    [self unbindWithOneTerminal:[[JYBinderTerminal alloc] initWithTarget:target1 keyPath:keyPath1] otherTerminal:[[JYBinderTerminal alloc] initWithTarget:target2 keyPath:keyPath2]];
}

#pragma mark - Key-Value

- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key {
    JYBinderTerminal *leadingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    return leadingTerminal;
}

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key {
    NSAssert(![JYBinderUtil isObjectNull:leadingTerminal], @"【JYBinder】: leadingTerminal为空");
    NSAssert([leadingTerminal isKindOfClass:[JYBinderTerminal class]], @"【JYBinder】: 无效的leadingTerminal");
    
    JYBinderTerminal *followingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    if (self.isTwoWay) {
        [JYBinder bindToTwoWayWithOneTerminal:leadingTerminal otherTerminal:followingTerminal];
    } else {
        [JYBinder bindToSingleWayWithLeading:leadingTerminal following:followingTerminal];
    }
}

@end
