//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"

@interface JYBinder ()

@property (nonatomic, weak) NSObject *target;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) BOOL isTwoWay;

@end

@implementation JYBinder

+ (void)bindToSingleWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal]];
}

+ (void)bindToTwoWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initTwoWayWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal]];
}

- (instancetype)initWithTarget:(NSObject *__weak)target keyPath:(NSString *)keyPath isTwoWay:(BOOL)isTwoWay {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.isTwoWay = isTwoWay;
    }
    return self;
}

- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key {
    JYBinderTerminal *leadingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    return leadingTerminal;
}

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key {
    NSCParameterAssert(leadingTerminal != nil);
    
    JYBinderTerminal *followingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    if (self.isTwoWay) {
        [JYBinder bindToTwoWayChannel:leadingTerminal followingTerminal:followingTerminal];
    } else {
        [JYBinder bindToSingleWayChannel:leadingTerminal followingTerminal:followingTerminal];
    }
}

@end
