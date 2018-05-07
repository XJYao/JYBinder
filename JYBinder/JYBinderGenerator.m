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
#import "JYBinderUtil.h"

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

+ (void)bindToSingleWayWithLeading:(JYBinderTerminal *)leadingTerminal following:(JYBinderTerminal *)followingTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal]];
}

+ (void)bindToTwoWayWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initTwoWayWithLeadingTerminal:terminal followingTerminal:otherTerminal]];
}

+ (void)unbindWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    [[JYBinderChannelManager sharedInstance] removeChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:terminal followingTerminal:otherTerminal]];
}

+ (void)unbindWithTarget1:(NSObject *__weak)target1 keyPath1:(NSString *)keyPath1 target2:(NSObject *__weak)target2 keyPath2:(NSString *)keyPath2 {
    [self unbindWithOneTerminal:[[JYBinderTerminal alloc] initWithTarget:target1 keyPath:keyPath1] otherTerminal:[[JYBinderTerminal alloc] initWithTarget:target2 keyPath:keyPath2]];
}

- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key {
    NSAssert([JYBinderUtil isEqualFromString:key toString:JYBinderKey], @"无效的Key");
    JYBinderTerminal *leadingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    return leadingTerminal;
}

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key {
    NSAssert([JYBinderUtil isEqualFromString:key toString:JYBinderKey], @"无效的Key");
    NSAssert(![JYBinderUtil isObjectNull:leadingTerminal], @"leadingTerminal为空");
    NSAssert([leadingTerminal isKindOfClass:[JYBinderTerminal class]], @"无效的leadingTerminal");
    
    JYBinderTerminal *followingTerminal = [[JYBinderTerminal alloc] initWithTarget:self.target keyPath:self.keyPath];
    if (self.isTwoWay) {
        [JYBinderGenerator bindToTwoWayWithOneTerminal:leadingTerminal otherTerminal:followingTerminal];
    } else {
        [JYBinderGenerator bindToSingleWayWithLeading:leadingTerminal following:followingTerminal];
    }
}

@end
