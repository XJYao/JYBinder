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
#import "NSObject+JYBinderDeallocating.h"

@interface JYBinderProxy ()

@property (nonatomic, strong) NSMapTable/* object pointer, NSMapTable *<keyPath, node> */ *safeMapTable;
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
        
        self.safeMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return self;
}

- (void)addObserverForNode:(JYBinderNode *)node {
    if ([JYBinderUtil isObjectNull:node] || [JYBinderUtil isObjectNull:node.object] || [JYBinderUtil isStringEmpty:node.keyPath]) {
        return;
    }

    void *objectPointer = (__bridge void *)node.object;
    if (!objectPointer) {
        return;
    }
    NSValue *objectPointerValue = [NSValue valueWithPointer:objectPointer];
    if ([JYBinderUtil isObjectNull:objectPointerValue]) {
        return;
    }
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMapTable *nodeForKeyPathMapTable = [weak_self.safeMapTable objectForKey:objectPointerValue];
        if ([JYBinderUtil isObjectNull:nodeForKeyPathMapTable]) {
            nodeForKeyPathMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory capacity:0];
            [weak_self.safeMapTable setObject:nodeForKeyPathMapTable forKey:objectPointerValue];
        }
        JYBinderNode *oldNode = [nodeForKeyPathMapTable objectForKey:node.keyPath];
        if (![JYBinderUtil isObjectNull:oldNode]) {
            [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:(__bridge void *)oldNode];
            [nodeForKeyPathMapTable removeObjectForKey:node.keyPath];
        }
        
        [nodeForKeyPathMapTable setObject:node forKey:node.keyPath];
        
        [node.object deallocDisposable:^(id deallocObject) {
            [weak_self removeObserversForObject:deallocObject];
        }];
        
        [node.object addObserver:weak_self forKeyPath:node.keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:(__bridge void *)node];
    });
}

- (void)removeObserverForObject:(NSObject *)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return;
    }
    void *objectPointer = (__bridge void *)object;
    if (!objectPointer) {
        return;
    }
    NSValue *objectPointerValue = [NSValue valueWithPointer:objectPointer];
    if ([JYBinderUtil isObjectNull:objectPointerValue]) {
        return;
    }
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMapTable *nodeForKeyPathMapTable = [weak_self.safeMapTable objectForKey:objectPointerValue];
        JYBinderNode *oldNode = [nodeForKeyPathMapTable objectForKey:keyPath];
        if (![JYBinderUtil isObjectNull:oldNode]) {
            [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:(__bridge void *)oldNode];
            [nodeForKeyPathMapTable removeObjectForKey:keyPath];
        }
        if (nodeForKeyPathMapTable.count == 0) {
            [weak_self.safeMapTable removeObjectForKey:objectPointerValue];
        }
    });
}

- (void)removeObserversForObject:(NSObject *)object {
    if ([JYBinderUtil isObjectNull:object]) {
        return;
    }
    void *objectPointer = (__bridge void *)object;
    if (!objectPointer) {
        return;
    }
    NSValue *objectPointerValue = [NSValue valueWithPointer:objectPointer];
    if ([JYBinderUtil isObjectNull:objectPointerValue]) {
        return;
    }
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMapTable *nodeForKeyPathMapTable = [weak_self.safeMapTable objectForKey:objectPointerValue];
        
        NSEnumerator *enumerator = [nodeForKeyPathMapTable keyEnumerator];
        NSString *keyPath = nil;
        while (![JYBinderUtil isStringEmpty:(keyPath = [enumerator nextObject])]) {
            JYBinderNode *oldNode = [nodeForKeyPathMapTable objectForKey:keyPath];
            if (![JYBinderUtil isObjectNull:oldNode]) {
                [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:(__bridge void *)oldNode];
            }
        }
        [weak_self.safeMapTable removeObjectForKey:objectPointerValue];
    });
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    void *objectPointer = (__bridge void *)object;
    if (!objectPointer) {
        return;
    }
    NSValue *objectPointerValue = [NSValue valueWithPointer:objectPointer];
    if ([JYBinderUtil isObjectNull:objectPointerValue]) {
        return;
    }
    
    __block JYBinderNode *node;
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMapTable *nodeForKeyPathMapTable = [weak_self.safeMapTable objectForKey:objectPointerValue];
        node = [nodeForKeyPathMapTable objectForKey:keyPath];
    });
    
    if (![JYBinderUtil isObjectNull:node]) {
        [node observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
