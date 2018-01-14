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
//#import "NSObject+JYBinderDeallocating.h"

@interface JYBinderProxy ()

@property (nonatomic, strong) NSMapTable/* object, NSDictionary *<keyPath, node> */ *binderMapTable;
@property (nonatomic, strong) NSMapTable/* object, NSDictionary *<keyPath, node> */ *bindedMapTable;
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

- (void)addObserverForNode:(JYBinderNode *)node {
    if ([JYBinderUtil isObjectNull:node] || [JYBinderUtil isObjectNull:node.object] || [JYBinderUtil isStringEmpty:node.keyPath]) {
        return;
    }

    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.binderMapTable objectForKey:node.object];
        if ([JYBinderUtil isObjectNull:nodeForKeyPathDict]) {
            nodeForKeyPathDict = [NSMutableDictionary dictionary];
            [weak_self.binderMapTable setObject:nodeForKeyPathDict forKey:node.object];
        }
        JYBinderNode *oldNode = [nodeForKeyPathDict objectForKey:node.keyPath];
        if ([JYBinderUtil isObjectNull:oldNode]) {
            [nodeForKeyPathDict setObject:node forKey:node.keyPath];
            
            [node.object addObserver:weak_self forKeyPath:node.keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        } else if (oldNode != node) {
            NSMutableSet *newBindingNodes = [NSMutableSet set];
            for (JYBinderNode *newBindingNode in node.bindingNodes) {
                if ([JYBinderUtil isObjectNull:newBindingNode.object] || [JYBinderUtil isStringEmpty:newBindingNode.keyPath]) {
                    continue;
                }
                BOOL found = NO;
                for (JYBinderNode *oldBindingNode in oldNode.bindingNodes) {
                    if ([JYBinderUtil isObjectNull:oldBindingNode.object] || [JYBinderUtil isStringEmpty:oldBindingNode.keyPath]) {
                        continue;
                    }
                    if ((newBindingNode.object == oldBindingNode.object) &&
                        [JYBinderUtil isEqualFromString:newBindingNode.keyPath toString:oldBindingNode.keyPath]) {
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [newBindingNodes addObject:newBindingNode];
                }
            }
            for (JYBinderNode *newBindingNode in newBindingNodes) {
                [oldNode.bindingNodes addObject:newBindingNode];
            }
        }
    });
}

- (void)addBindedNode:(JYBinderNode *)node {
    if ([JYBinderUtil isObjectNull:node] || [JYBinderUtil isObjectNull:node.object] || [JYBinderUtil isStringEmpty:node.keyPath]) {
        return;
    }
    
    NSMutableDictionary *nodeForKeyPathDict = [self.bindedMapTable objectForKey:node.object];
    if ([JYBinderUtil isObjectNull:nodeForKeyPathDict]) {
        nodeForKeyPathDict = [NSMutableDictionary dictionary];
        [self.bindedMapTable setObject:nodeForKeyPathDict forKey:node.object];
    }
    [nodeForKeyPathDict setObject:node forKey:node.keyPath];
}

- (void)removeObserverForObject:(NSObject *)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return;
    }
    __weak typeof(self) weak_self = self;

    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.binderMapTable objectForKey:object];
        JYBinderNode *oldNode = [nodeForKeyPathDict objectForKey:keyPath];
        if (![JYBinderUtil isObjectNull:oldNode]) {
            [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:NULL];
            [nodeForKeyPathDict removeObjectForKey:keyPath];
        }
        if (nodeForKeyPathDict.count == 0) {
            [weak_self.binderMapTable removeObjectForKey:object];
        }
    });
}

- (void)removeObserversForObject:(NSObject *)object {
    if ([JYBinderUtil isObjectNull:object]) {
        return;
    }
    __weak typeof(self) weak_self = self;

    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.binderMapTable objectForKey:object];
        for (JYBinderNode *oldNode in nodeForKeyPathDict.allValues) {
            if (![JYBinderUtil isObjectNull:oldNode]) {
                [oldNode.object removeObserver:weak_self forKeyPath:oldNode.keyPath context:NULL];
            }
        }
        [weak_self.binderMapTable removeObjectForKey:object];
    });
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    __block JYBinderNode *node;
    __weak typeof(self) weak_self = self;
    
    dispatch_sync(self.queue, ^{
        NSMutableDictionary *nodeForKeyPathDict = [weak_self.binderMapTable objectForKey:object];
        node = [nodeForKeyPathDict objectForKey:keyPath];
    });
    
    if (![JYBinderUtil isObjectNull:node]) {
        [node observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - lazy

- (NSMapTable *)binderMapTable {
    if (!_binderMapTable) {
        _binderMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return _binderMapTable;
}

- (NSMapTable *)bindedMapTable {
    if (!_bindedMapTable) {
        _bindedMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return _bindedMapTable;
}

@end
