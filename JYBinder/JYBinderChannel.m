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
//#import "NSObject+JYBinderDeallocating.h"
#import "NSObject+JYBinderObject.h"

@interface JYBinderChannel ()

@property (nonatomic, strong) JYBinderTerminal *theLeadingTerminal;

@property (nonatomic, strong) JYBinderTerminal *theFollowingTerminal;

/**
 是否已注册KVO
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
@property (nonatomic, strong) dispatch_semaphore_t lock;

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
    __weak typeof(self) weak_self = self;
    
    if (!self.leadingTerminalObserving) {
        [self.leadingTerminal.target addObserver:self forKeyPath:self.leadingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.leadingTerminal)];
        self.leadingTerminalObserving = YES;
        
        [self.leadingTerminal.target observerDealloc:^{
            [weak_self removeObserver];
        }];
    }
    
    if (!self.followingTerminalObserving && self.isTwoWay) {
        [self.followingTerminal.target addObserver:self forKeyPath:self.followingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.followingTerminal)];
        self.followingTerminalObserving = YES;

        [self.followingTerminal.target observerDealloc:^{
            [weak_self removeObserver];
        }];
    }
    
    id value = [self.leadingTerminal.target valueForKey:self.leadingTerminal.keyPath];
    [self.leadingTerminal.target setValue:value forKey:self.leadingTerminal.keyPath];
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
    
    if (self.isTwoWay) {
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        
        //双向绑定情况下，A->B，B->A，会造成死循环，所以需过滤B通知A修改的情况
        if (self.ignoreNextUpdate) {
            self.ignoreNextUpdate = NO;
            
            dispatch_semaphore_signal(self.lock);
            return;
        }
        self.ignoreNextUpdate = YES;
        dispatch_semaphore_signal(self.lock);
    }
    
    JYBinderTerminal *terminal = (__bridge JYBinderTerminal *)(context);
    if ([JYBinderUtil isObjectNull:terminal]) {
        if (self.isTwoWay) {
            self.ignoreNextUpdate = NO;
        }
        return;
    }
    
    JYBinderTerminal *otherTerminal = nil;
    if (terminal == self.leadingTerminal) {
        otherTerminal = self.followingTerminal;
    } else if (terminal == self.followingTerminal) {
        otherTerminal = self.leadingTerminal;
    } else {
        if (self.isTwoWay) {
            self.ignoreNextUpdate = NO;
        }
        return;
    }
    
    id value = [object valueForKey:keyPath];
    //对值做自定义转换
    if (otherTerminal.map) {
        value = otherTerminal.map(value);
    }

    if (otherTerminal.queue) {
        //在指定线程中赋值
        __weak typeof(otherTerminal) weak_otherTerminal = otherTerminal;
        dispatch_async(weak_otherTerminal.queue, ^{
            [weak_otherTerminal.target setValue:value forKey:weak_otherTerminal.keyPath];
        });
    } else {
        [otherTerminal.target setValue:value forKey:otherTerminal.keyPath];
    }
}

#pragma mark - lazy

- (dispatch_semaphore_t)lock {
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
    return _lock;
}

@end
