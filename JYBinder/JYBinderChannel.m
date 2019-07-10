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
#import "NSObject+JYBinderObject.h"

@interface JYBinderChannel ()

/**
 是否已注册KVO
 */
@property (nonatomic, assign) BOOL leadingTerminalObserving;

@property (nonatomic, assign) BOOL followingTerminalObserving;

/**
 防止死循环
 */
@property (nonatomic, assign) BOOL ignoreNextUpdate;

@end

@implementation JYBinderChannel

- (instancetype)initSingleWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal {
    return [self initWithLeadingTerminal:leadingTerminal followingTerminal:followingTerminal twoWay:NO];
}

- (instancetype)initTwoWayWithOneTerminal:(JYBinderTerminal *)oneTerminal otherTerminal:(JYBinderTerminal *)otherTerminal {
    return [self initWithLeadingTerminal:oneTerminal followingTerminal:otherTerminal twoWay:YES];
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
        self.isTwoWay = twoWay;
        self.leadingTerminalObserving = NO;
        self.followingTerminalObserving = NO;
        self.ignoreNextUpdate = NO;
        
        self.leadingTerminal = leadingTerminal;
        self.followingTerminal = followingTerminal;
    }
    return self;
}

- (void)addObserver {
    @synchronized (self) {
        __weak typeof(self) weakSelf = self;
        
        if (!self.leadingTerminalObserving) {
            [self.leadingTerminal.target addObserver:self forKeyPath:self.leadingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.leadingTerminal)];
            self.leadingTerminalObserving = YES;
            
            [self.leadingTerminal.target observerDealloc:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf removeObserver];
                }
            }];
        }
        
        if (!self.followingTerminalObserving && self.isTwoWay) {
            [self.followingTerminal.target addObserver:self forKeyPath:self.followingTerminal.keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self.followingTerminal)];
            self.followingTerminalObserving = YES;
            
            [self.followingTerminal.target observerDealloc:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf removeObserver];
                }
            }];
        }
        
        id value = [self.leadingTerminal.target valueForKey:self.leadingTerminal.keyPath];
        [self.leadingTerminal.target setValue:value forKey:self.leadingTerminal.keyPath];
    }
}

- (void)removeObserver {
    @synchronized (self) {
        if (self.leadingTerminalObserving) {
            [self.leadingTerminal.target removeObserver:self forKeyPath:self.leadingTerminal.keyPath context:(__bridge void * _Nullable)(self.leadingTerminal)];
            self.leadingTerminalObserving = NO;
        }
        if (self.followingTerminalObserving) {
            [self.followingTerminal.target removeObserver:self forKeyPath:self.followingTerminal.keyPath context:(__bridge void * _Nullable)(self.followingTerminal)];
            self.followingTerminalObserving = NO;
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (self.isTwoWay) {
        BOOL shouldReturn = NO;
        @synchronized (self) {
            //双向绑定情况下，A->B，B->A，会造成死循环，所以需过滤B通知A修改的情况
            if (self.ignoreNextUpdate) {
                self.ignoreNextUpdate = NO;
                
                shouldReturn = YES;
            } else {
                self.ignoreNextUpdate = YES;
            }
        }
        if (shouldReturn) {
            return;
        }
    }
    
    JYBinderTerminal *terminal = (__bridge JYBinderTerminal *)(context);
    if ([JYBinderUtil isObjectNull:terminal]) {
        if (self.isTwoWay) {
            @synchronized (self) {
                self.ignoreNextUpdate = NO;
            }
        }
        return;
    }
    
    JYBinderTerminal *otherTerminal = nil;
    if (self.isTwoWay) {
        BOOL shouldReturn = NO;
        @synchronized (self) {
            if (terminal == self.leadingTerminal) {
                otherTerminal = self.followingTerminal;
            } else if (terminal == self.followingTerminal) {
                otherTerminal = self.leadingTerminal;
            } else {
                self.ignoreNextUpdate = NO;
                shouldReturn = YES;
            }
        }
        if (shouldReturn) {
            return;
        }
    } else {
        @synchronized (self) {
            otherTerminal = self.followingTerminal;
        }
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
            __strong typeof(weak_otherTerminal) strong_otherTerminal = weak_otherTerminal;
            if (strong_otherTerminal) {
                [strong_otherTerminal.target setValue:value forKey:weak_otherTerminal.keyPath];
            }
        });
    } else {
        [otherTerminal.target setValue:value forKey:otherTerminal.keyPath];
    }
}

@end
