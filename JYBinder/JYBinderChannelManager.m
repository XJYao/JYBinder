//
//  JYBinderChannelManager.m
//  JYBinder
//
//  Created by XJY on 2018/3/3.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderChannelManager.h"
#import "JYBinderUtil.h"
#import "JYBinderChannel.h"
#import "JYBinderTerminal.h"

@interface JYBinderChannelManager ()

/**
 target1->keypath1->target2->keypath2->channel
 并且弱引用target
 */
@property (nonatomic, strong) NSMapTable *channels;

@end

@implementation JYBinderChannelManager

#pragma mark - Public

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channels = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)addChannel:(JYBinderChannel *)channel {
    if ([JYBinderUtil isObjectNull:channel]) {
        return;
    }
    if (![channel isKindOfClass:[JYBinderChannel class]]) {
        return;
    }
    if ([JYBinderUtil isObjectNull:channel.leadingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.leadingTerminal.keyPath] ||
        [JYBinderUtil isObjectNull:channel.followingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.followingTerminal.keyPath]) {
        return;
    }
    
    //同一对终端只能存在一个通道，如果已存在就不再做保存。
    JYBinderChannel *existChannel = [self existChannelWithLeadingTerminal:channel.leadingTerminal followingTerminal:channel.followingTerminal shouldRemove:NO];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        [existChannel addObserver];
        return;
    }
    existChannel = [self existChannelWithLeadingTerminal:channel.followingTerminal followingTerminal:channel.leadingTerminal shouldRemove:NO];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        [existChannel addObserver];
        return;
    }
    
    @synchronized (self) {
        NSMapTable *leadingKeyToFollowT = [self.channels objectForKey:channel.leadingTerminal.target];
        if ([JYBinderUtil isObjectNull:leadingKeyToFollowT]) {
            leadingKeyToFollowT = [NSMapTable strongToStrongObjectsMapTable];
            [self.channels setObject:leadingKeyToFollowT forKey:channel.leadingTerminal.target];
        }
        NSMapTable *followTargetToKey = [leadingKeyToFollowT objectForKey:channel.leadingTerminal.keyPath];
        if ([JYBinderUtil isObjectNull:followTargetToKey]) {
            followTargetToKey = [NSMapTable weakToStrongObjectsMapTable];
            [leadingKeyToFollowT setObject:followTargetToKey forKey:channel.leadingTerminal.keyPath];
        }
        NSMapTable *followKeyToChannel = [followTargetToKey objectForKey:channel.followingTerminal.target];
        if ([JYBinderUtil isObjectNull:followKeyToChannel]) {
            followKeyToChannel = [NSMapTable strongToStrongObjectsMapTable];
            [followTargetToKey setObject:followKeyToChannel forKey:channel.followingTerminal.target];
        }
        [followKeyToChannel setObject:channel forKey:channel.followingTerminal.keyPath];
    }
    
    [channel addObserver];
}

- (void)removeChannel:(JYBinderChannel *)channel {
    if ([JYBinderUtil isObjectNull:channel]) {
        return;
    }
    if (![channel isKindOfClass:[JYBinderChannel class]]) {
        return;
    }
    if ([JYBinderUtil isObjectNull:channel.leadingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.leadingTerminal.keyPath] ||
        [JYBinderUtil isObjectNull:channel.followingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.followingTerminal.keyPath]) {
        return;
    }
    
    JYBinderChannel *existChannel = [self existChannelWithLeadingTerminal:channel.leadingTerminal followingTerminal:channel.followingTerminal shouldRemove:YES];
    if ([JYBinderUtil isObjectNull:existChannel]) {
        existChannel = [self existChannelWithLeadingTerminal:channel.followingTerminal followingTerminal:channel.leadingTerminal shouldRemove:YES];
    }
    [existChannel removeObserver];
}

#pragma mark - Private

- (JYBinderChannel *)existChannelWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal shouldRemove:(BOOL)shouldRemove {
    
    JYBinderChannel *channel = nil;
    @synchronized (self) {
        NSMapTable *leadingKeyToFollowT = [self.channels objectForKey:leadingTerminal.target];
        if (![JYBinderUtil isObjectNull:leadingKeyToFollowT]) {
            NSMapTable *followTargetToKey = [leadingKeyToFollowT objectForKey:leadingTerminal.keyPath];
            if (![JYBinderUtil isObjectNull:followTargetToKey]) {
                NSMapTable *followKeyToChannel = [followTargetToKey objectForKey:followingTerminal.target];
                if (![JYBinderUtil isObjectNull:followKeyToChannel]) {
                    channel = [followKeyToChannel objectForKey:followingTerminal.keyPath];
                    
                    if (shouldRemove) {
                        [followKeyToChannel removeObjectForKey:followingTerminal.keyPath];
                    }
                }
            }
        }
    }
    
    return channel;
}

@end
