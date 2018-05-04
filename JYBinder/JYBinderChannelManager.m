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

@property (nonatomic, strong) NSMapTable *channels;

@property (nonatomic, strong) NSLock *lock;

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

- (void)addChannel:(JYBinderChannel *)channel {
    if ([JYBinderUtil isObjectNull:channel.leadingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.leadingTerminal.keyPath] ||
        [JYBinderUtil isObjectNull:channel.followingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.followingTerminal.keyPath]) {
        return;
    }
    
    [self.lock lock];
    
    JYBinderChannel *existChannel = [self existChannelWithLeadingTerminal:channel.leadingTerminal followingTerminal:channel.followingTerminal shouldRemove:NO];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        [existChannel addObserver];
        [self.lock unlock];
        return;
    }
    existChannel = [self existChannelWithLeadingTerminal:channel.followingTerminal followingTerminal:channel.leadingTerminal shouldRemove:NO];
    if (![JYBinderUtil isObjectNull:existChannel]) {
        [existChannel addObserver];
        [self.lock unlock];
        return;
    }
    
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
    [channel addObserver];
    
    [self.lock unlock];
}

- (void)removeChannel:(JYBinderChannel *)channel {
    if ([JYBinderUtil isObjectNull:channel.leadingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.leadingTerminal.keyPath] ||
        [JYBinderUtil isObjectNull:channel.followingTerminal.target] ||
        [JYBinderUtil isStringEmpty:channel.followingTerminal.keyPath]) {
        return;
    }
    
    [self.lock lock];
    
    JYBinderChannel *existChannel = [self existChannelWithLeadingTerminal:channel.leadingTerminal followingTerminal:channel.followingTerminal shouldRemove:YES];
    if ([JYBinderUtil isObjectNull:existChannel]) {
        existChannel = [self existChannelWithLeadingTerminal:channel.followingTerminal followingTerminal:channel.leadingTerminal shouldRemove:YES];
    }
    [existChannel removeObserver];
    
    [self.lock unlock];
}

#pragma mark - Private

- (JYBinderChannel *)existChannelWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal shouldRemove:(BOOL)shouldRemove {
    NSMapTable *leadingKeyToFollowT = [self.channels objectForKey:leadingTerminal.target];
    if ([JYBinderUtil isObjectNull:leadingKeyToFollowT]) {
        return nil;
    }
    NSMapTable *followTargetToKey = [leadingKeyToFollowT objectForKey:leadingTerminal.keyPath];
    if ([JYBinderUtil isObjectNull:followTargetToKey]) {
        return nil;
    }
    NSMapTable *followKeyToChannel = [followTargetToKey objectForKey:followingTerminal.target];
    if ([JYBinderUtil isObjectNull:followKeyToChannel]) {
        return nil;
    }
    JYBinderChannel *channel = [followKeyToChannel objectForKey:followingTerminal.keyPath];
    if (shouldRemove) {
        [followKeyToChannel removeObjectForKey:followingTerminal.keyPath];
    }
    return channel;
}

#pragma mark - lazy

- (NSMapTable *)channels {
    if ([JYBinderUtil isObjectNull:_channels]) {
        _channels = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _channels;
}

- (NSLock *)lock {
    if ([JYBinderUtil isObjectNull:_lock]) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end
