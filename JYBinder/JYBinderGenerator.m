//
//  JYBinderGenerator.m
//  JYBinder
//
//  Created by XJY on 2018/3/3.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderGenerator.h"
#import "JYBinderTerminal.h"
#import "JYBinderChannelManager.h"
#import "JYBinderChannel.h"

@interface JYBinderGenerator ()

@property (nonatomic, weak) NSObject *target;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) BOOL isTwoWay;

@end

@implementation JYBinderGenerator

- (instancetype)initWithTarget:(NSObject *__weak)target keyPath:(NSString *)keyPath isTwoWay:(BOOL)isTwoWay {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.isTwoWay = isTwoWay;
    }
    return self;
}

+ (void)bindToSingleWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal]];
}

+ (void)bindToTwoWayChannel:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initTwoWayWithLeadingTerminal:terminal followingTerminal:otherTerminal]];
}

+ (void)unbindWithTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] removeChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:terminal followingTerminal:otherTerminal]];
}

+ (void)unbindWithTarget1:(NSObject *__weak)target1 keyPath1:(NSString *)keyPath1 target2:(NSObject *__weak)target2 keyPath2:(NSString *)keyPath2 {
    [self unbindWithTerminal:[[JYBinderTerminal alloc] initWithTarget:target1 keyPath:keyPath1] otherTerminal:[[JYBinderTerminal alloc] initWithTarget:target2 keyPath:keyPath2]];
}

- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key {
    JYBinderTerminal *leadingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    return leadingTerminal;
}

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key {
    NSCParameterAssert(leadingTerminal != nil);
    
    JYBinderTerminal *followingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    if (self.isTwoWay) {
        [JYBinderGenerator bindToTwoWayChannel:leadingTerminal otherTerminal:followingTerminal];
    } else {
        [JYBinderGenerator bindToSingleWayChannel:leadingTerminal followingTerminal:followingTerminal];
    }
}

@end
