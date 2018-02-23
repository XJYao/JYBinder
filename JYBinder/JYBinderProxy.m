//
//  JYBinderProxy.m
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderProxy.h"
#import "JYBinderUtil.h"
#import "JYBinderNode.h"

@interface JYBinderProxy ()

@property (nonatomic, strong) NSMapTable/* object, NSDictionary *<keyPath, node> */ *nodeMapTable;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation JYBinderProxy

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
        self.queue = dispatch_queue_create("com.jy.JYBinderProxy", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (JYBinderNode *)addObserverForObject:(NSObject *)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return nil;
    }
    
    __block JYBinderNode *node = nil;

    __weak typeof(self) weak_self = self;
    dispatch_sync(self.queue, ^{
        node = [weak_self addObject:object keyPath:keyPath isObserver:YES];
    });
    
    return node;
}

- (JYBinderNode *)addBindedWithObject:(NSObject *)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return nil;
    }
    
    __block JYBinderNode *node = nil;
    
    __weak typeof(self) weak_self = self;
    dispatch_sync(self.queue, ^{
        node = [weak_self addObject:object keyPath:keyPath isObserver:NO];
    });
    
    return node;
}

- (JYBinderNode *)addObject:(NSObject *)object keyPath:(NSString *)keyPath isObserver:(BOOL)isObserver {
    NSMutableDictionary *nodeForKeyPathDict = [self.nodeMapTable objectForKey:object];
    if ([JYBinderUtil isObjectNull:nodeForKeyPathDict]) {
        nodeForKeyPathDict = [NSMutableDictionary dictionary];
        [self.nodeMapTable setObject:nodeForKeyPathDict forKey:object];
    }
    JYBinderNode *oldNode = [nodeForKeyPathDict objectForKey:keyPath];
    
    if ([JYBinderUtil isObjectNull:oldNode]) {
        oldNode = [[JYBinderNode alloc] initWithObject:object keyPath:keyPath];
        
        [nodeForKeyPathDict setObject:oldNode forKey:keyPath];
    }
    
    if (isObserver && !oldNode.isRegisteredAsAnObserver) {
        [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        [oldNode setIsRegisteredAsAnObserver:YES];
    }
    
    return oldNode;
}

- (void)removeWithObject:(NSObject *)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return;
    }
    __weak typeof(self) weak_self = self;

    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.nodeMapTable objectForKey:object];
        JYBinderNode *oldNode = [nodeForKeyPathDict objectForKey:keyPath];
        if (![JYBinderUtil isObjectNull:oldNode]) {
            if (oldNode.isRegisteredAsAnObserver) {
                [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:NULL];
                [oldNode setIsRegisteredAsAnObserver:NO];
            }
            [nodeForKeyPathDict removeObjectForKey:keyPath];
        }
        if (nodeForKeyPathDict.count == 0) {
            [weak_self.nodeMapTable removeObjectForKey:object];
        }
    });
}

- (void)removeWithObject:(NSObject *)object {
    if ([JYBinderUtil isObjectNull:object]) {
        return;
    }
    __weak typeof(self) weak_self = self;

    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.nodeMapTable objectForKey:object];
        for (JYBinderNode *oldNode in nodeForKeyPathDict.allValues) {
            if (![JYBinderUtil isObjectNull:oldNode]) {
                if (oldNode.isRegisteredAsAnObserver) {
                    [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:NULL];
                    [oldNode setIsRegisteredAsAnObserver:NO];
                }
            }
        }
        [weak_self.nodeMapTable removeObjectForKey:object];
    });
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    __block JYBinderNode *node;
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.nodeMapTable objectForKey:object];
        node = [nodeForKeyPathDict objectForKey:keyPath];
    });
    
    if (![JYBinderUtil isObjectNull:node]) {
        [node observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - lazy

- (NSMapTable *)nodeMapTable {
    if (!_nodeMapTable) {
        _nodeMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return _nodeMapTable;
}

@end
