//
//  JYBinderChannel.m
//  JYBinder
//
//  Created by XJY on 2018/5/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderChannel.h"
#import "JYBinderUtil.h"
#import "JYBinderTerminal.h"
#import "JYBinderSafeMapTable.h"
#import "NSObject+JYBinderDeallocating.h"

@interface JYBinderChannel ()

@property (nonatomic, strong) JYBinderTerminal *leadingTerminal;

@property (nonatomic, strong) JYBinderTerminal *followingTerminal;

@property (nonatomic, assign) BOOL leadingTerminalObserving;

@property (nonatomic, assign) BOOL followingTerminalObserving;

@property (nonatomic, assign) BOOL ignoreNextUpdate;

@end

@implementation JYBinderChannel

- (instancetype)initWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    self = [super init];
    if (self) {
        self.leadingTerminalObserving = NO;
        self.followingTerminalObserving = NO;
        
        self.ignoreNextUpdate = NO;
        
        self.leadingTerminal = leadingTerminal;
        self.followingTerminal = followingTerminal;
        
        self.leadingTerminal.otherTerminal = self.followingTerminal;
        self.followingTerminal.otherTerminal = self.leadingTerminal;
        
        [self addObserver];
        [[JYBinderChannelsManager sharedInstance] addChannel:self];
    }
    return self;
}

- (void)addObserver {
    __weak typeof(self) weak_self = self;
    
    if (!self.leadingTerminalObserving) {
        [self.leadingTerminal.target addObserver:self forKeyPath:self.leadingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.leadingTerminal)];
        self.leadingTerminalObserving = YES;
        
        [self.leadingTerminal.target addRemoveObserverWhenDeallocBlock:^(NSObject *deallocObject) {
            [weak_self removeObserver];
        }];
    }
    
    if (!self.followingTerminalObserving) {
        [self.followingTerminal.target addObserver:self forKeyPath:self.followingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.followingTerminal)];
        self.followingTerminalObserving = YES;
        
        [self.followingTerminal.target addRemoveObserverWhenDeallocBlock:^(NSObject *deallocObject) {
            [weak_self removeObserver];
        }];
    }
}

- (void)removeObserver {
    if (self.leadingTerminalObserving) {
        [self.leadingTerminal.target removeObserver:self forKeyPath:self.leadingTerminal.keyPath context:(__bridge void * _Nullable)(self.leadingTerminal)];
        self.leadingTerminalObserving = NO;
    }
    if (self.followingTerminalObserving) {
        [self.followingTerminal.target removeObserver:self forKeyPath:self.followingTerminal.keyPath context:(__bridge void * _Nullable)(self.followingTerminal)];
        self.followingTerminalObserving = NO;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.ignoreNextUpdate) {
        self.ignoreNextUpdate = NO;
        return;
    }
    self.ignoreNextUpdate = YES;
    
    JYBinderTerminal *terminal = (__bridge JYBinderTerminal *)(context);
    [terminal.otherTerminal.target setValue:[change objectForKey:@"new"] forKey:terminal.otherTerminal.keyPath];
}

@end

@interface JYBinderChannelsManager ()

@property (nonatomic, strong) JYBinderSafeMapTable *channels;

@end

@implementation JYBinderChannelsManager

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)addChannel:(JYBinderChannel *)channel {
    if ([JYBinderUtil isObjectNull:channel.leadingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.leadingTerminal.keyPath] ||
        [JYBinderUtil isObjectNull:channel.followingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.followingTerminal.keyPath]) {
        return;
    }
    JYBinderChannel *existChannel = [self existChannelWithLeadingTerminal:channel.leadingTerminal followingTerminal:channel.followingTerminal];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        return;
    }
    existChannel = [self existChannelWithLeadingTerminal:channel.followingTerminal followingTerminal:channel.leadingTerminal];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        return;
    }
    
    JYBinderSafeMapTable *leadingKeyToFollowT = [self.channels objectForKey:channel.leadingTerminal.target];
    if ([JYBinderUtil isObjectNull:leadingKeyToFollowT]) {
        leadingKeyToFollowT = [[JYBinderSafeMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        [self.channels setObject:leadingKeyToFollowT forKey:channel.leadingTerminal.target];
    }
    JYBinderSafeMapTable *followTargetToKey = [leadingKeyToFollowT objectForKey:channel.leadingTerminal.keyPath];
    if ([JYBinderUtil isObjectNull:followTargetToKey]) {
        followTargetToKey = [[JYBinderSafeMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
        [leadingKeyToFollowT setObject:followTargetToKey forKey:channel.leadingTerminal.keyPath];
    }
    JYBinderSafeMapTable *followKeyToChannel = [followTargetToKey objectForKey:channel.followingTerminal.target];
    if ([JYBinderUtil isObjectNull:followKeyToChannel]) {
        followKeyToChannel = [[JYBinderSafeMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        [followTargetToKey setObject:followKeyToChannel forKey:channel.followingTerminal.target];
    }
    [followKeyToChannel setObject:channel forKey:channel.followingTerminal.keyPath];
}

- (JYBinderChannel *)existChannelWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    JYBinderSafeMapTable *leadingKeyToFollowT = [self.channels objectForKey:leadingTerminal.target];
    if ([JYBinderUtil isObjectNull:leadingKeyToFollowT]) {
        return nil;
    }
    JYBinderSafeMapTable *followTargetToKey = [leadingKeyToFollowT objectForKey:leadingTerminal.keyPath];
    if ([JYBinderUtil isObjectNull:followTargetToKey]) {
        return nil;
    }
    JYBinderSafeMapTable *followKeyToChannel = [followTargetToKey objectForKey:followingTerminal.target];
    if ([JYBinderUtil isObjectNull:followKeyToChannel]) {
        return nil;
    }
    return [followKeyToChannel objectForKey:followingTerminal.keyPath];
}

#pragma mark - lazy

- (JYBinderSafeMapTable *)channels {
    if ([JYBinderUtil isObjectNull:_channels]) {
        _channels = [[JYBinderSafeMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _channels;
}

@end
