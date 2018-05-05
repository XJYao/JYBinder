//
//  JYBinderChannel.m
//  JYBinder
//
//  Created by XJY on 2018/3/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderChannel.h"
#import "JYBinderUtil.h"
#import "JYBinderTerminal.h"
#import "NSObject+JYBinderDeallocating.h"

@interface JYBinderChannel ()

@property (nonatomic, strong) JYBinderTerminal *theLeadingTerminal;

@property (nonatomic, strong) JYBinderTerminal *theFollowingTerminal;

/**
 是否已监听KVO
 */
@property (nonatomic, assign) BOOL leadingTerminalObserving;

@property (nonatomic, assign) BOOL followingTerminalObserving;

/**
 防止死循环
 */
@property (nonatomic, assign) BOOL ignoreNextUpdate;

/**
 是否双向
 */
@property (nonatomic, assign) BOOL twoWay;

/**
 线程锁
 */
@property (nonatomic, strong) NSLock *lock;

@end

@implementation JYBinderChannel

- (instancetype)initSingleWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    return [self initWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal twoWay:NO];
}

- (instancetype)initTwoWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    return [self initWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal twoWay:YES];
}

- (instancetype)initWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal twoWay:(BOOL)twoWay {
    if ([JYBinderUtil isObjectNull:leadingTerminal] || [JYBinderUtil isObjectNull:followingTerminal]) {
        return nil;
    }
    Class JYBinderTerminalClass = [JYBinderTerminal class];
    if (![leadingTerminal isKindOfClass:JYBinderTerminalClass] || ![followingTerminal isKindOfClass:JYBinderTerminalClass]) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.twoWay = twoWay;
        self.leadingTerminalObserving = NO;
        self.followingTerminalObserving = NO;
        
        self.ignoreNextUpdate = NO;
        
        self.theLeadingTerminal = leadingTerminal;
        self.theFollowingTerminal = followingTerminal;
        
        //两终端做关联
        self.leadingTerminal.otherTerminal = self.followingTerminal;
        
        if (self.twoWay) {
            self.followingTerminal.otherTerminal = self.leadingTerminal;
        }
    }
    return self;
}

- (BOOL)isTwoWay {
    return self.twoWay;
}

- (JYBinderTerminal *)leadingTerminal {
    return self.theLeadingTerminal;
}

- (JYBinderTerminal *)followingTerminal {
    return self.theFollowingTerminal;
}

- (void)addObserver {
    [self.lock lock];
    __weak typeof(self) weak_self = self;
    
    if (!self.leadingTerminalObserving && ![JYBinderUtil isObjectNull:self.leadingTerminal.otherTerminal]) {
        [self.leadingTerminal.target addObserver:self forKeyPath:self.leadingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.leadingTerminal)];
        self.leadingTerminalObserving = YES;
        
        [self.leadingTerminal.target addRemoveObserverWhenDeallocBlock:^(NSObject *deallocObject) {
            [weak_self removeObserver];
        }];
    }
    
    if (!self.followingTerminalObserving && ![JYBinderUtil isObjectNull:self.followingTerminal.otherTerminal]) {
        [self.followingTerminal.target addObserver:self forKeyPath:self.followingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.followingTerminal)];
        self.followingTerminalObserving = YES;
        
        [self.followingTerminal.target addRemoveObserverWhenDeallocBlock:^(NSObject *deallocObject) {
            [weak_self removeObserver];
        }];
    }
    
    [self.lock unlock];
    
    id value = [self.leadingTerminal.target valueForKey:self.leadingTerminal.keyPath];
    [self.leadingTerminal.target setValue:value forKey:self.leadingTerminal.keyPath];
}

- (void)removeObserver {
    [self lock];
    
    if (self.leadingTerminalObserving && ![JYBinderUtil isObjectNull:self.leadingTerminal.otherTerminal]) {
        [self.leadingTerminal.target removeObserver:self forKeyPath:self.leadingTerminal.keyPath context:(__bridge void * _Nullable)(self.leadingTerminal)];
        self.leadingTerminalObserving = NO;
    }
    if (self.followingTerminalObserving && ![JYBinderUtil isObjectNull:self.followingTerminal.otherTerminal]) {
        [self.followingTerminal.target removeObserver:self forKeyPath:self.followingTerminal.keyPath context:(__bridge void * _Nullable)(self.followingTerminal)];
        self.followingTerminalObserving = NO;
    }
    
    [self.lock unlock];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.isTwoWay) {
        [self.lock lock];
        //双向绑定情况下，A->B，B->A，会造成死循环，所以需过滤B通知A修改的情况
        if (self.ignoreNextUpdate) {
            self.ignoreNextUpdate = NO;
            
            [self.lock unlock];
            return;
        }
        self.ignoreNextUpdate = YES;
        [self.lock unlock];
    }
    
    JYBinderTerminal *terminal = (__bridge JYBinderTerminal *)(context);
    if ([JYBinderUtil isObjectNull:terminal.otherTerminal]) {
        return;
    }
    
    id value = [object valueForKey:keyPath];
    //对值做自定义转换
    if (terminal.otherTerminal.map) {
        value = terminal.otherTerminal.map(value);
    }
    
    [terminal.otherTerminal.target setValue:value forKey:terminal.otherTerminal.keyPath];
}

#pragma mark - lazy

- (NSLock *)lock {
    if ([JYBinderUtil isObjectNull:_lock]) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end
