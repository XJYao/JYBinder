//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"
#import "JYBinderNode.h"
#import "JYBinderProxy.h"
#import "JYBinderUtil.h"

@implementation JYBinder

+ (void)bindWithObjectsAndKeyPaths:(id)object1, ... {
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    va_list args;
    va_start(args, object1);
    {
        NSUInteger paramIndex = 0;
        
        for (id otherObject = object1; ![JYBinderUtil isObjectNull:otherObject]; otherObject = va_arg(args, id)) {
            
            if (paramIndex % 2 == 0) {
                [objects addObject:otherObject];
            } else {
                [keyPaths addObject:otherObject];
            }
            
            paramIndex ++;
        }
    }
    va_end(args);
    
    NSMutableSet *nodes = [NSMutableSet setWithCapacity:objects.count];
    for (NSInteger i = 0; i < objects.count; i ++) {
        id object = [objects objectAtIndex:i];
        id keyPath = nil;
        if (i < keyPaths.count) {
            keyPath = [keyPaths objectAtIndex:i];
        }
        if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
            continue;
        }
        JYBinderNode *node = [[JYBinderNode alloc] initWithObject:object keyPath:keyPath];
        [nodes addObject:node];
    }
    
    for (JYBinderNode *node in nodes) {
        NSHashTable *bindingNodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        for (JYBinderNode *bindingNode in nodes) {
            [bindingNodes addObject:bindingNode];
        }
        [bindingNodes removeObject:node];
        [node setBindingNodes:bindingNodes];
        
        [[JYBinderProxy sharedInstance] addObserverForNode:node];
    }
}

+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)object1, ... {
    if ([JYBinderUtil isObjectNull:sourceObject] || [JYBinderUtil isStringEmpty:sourceKeyPath]) {
        return;
    }
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    va_list args;
    va_start(args, object1);
    {
        NSUInteger paramIndex = 0;
        
        for (id otherObject = object1; ![JYBinderUtil isObjectNull:otherObject]; otherObject = va_arg(args, id)) {
            
            if (paramIndex % 2 == 0) {
                [objects addObject:otherObject];
            } else {
                [keyPaths addObject:otherObject];
            }
            
            paramIndex ++;
        }
    }
    va_end(args);
    
    NSHashTable *nodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    for (NSInteger i = 0; i < objects.count; i ++) {
        id object = [objects objectAtIndex:i];
        id keyPath = nil;
        if (i < keyPaths.count) {
            keyPath = [keyPaths objectAtIndex:i];
        }
        if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
            continue;
        }
        JYBinderNode *node = [[JYBinderNode alloc] initWithObject:object keyPath:keyPath];
        [nodes addObject:node];
        
        [[JYBinderProxy sharedInstance] addBindedNode:node];
    }
    
    JYBinderNode *sourceNode = [[JYBinderNode alloc] initWithObject:sourceObject keyPath:sourceKeyPath];
    [sourceNode setBindingNodes:nodes];
    
    [[JYBinderProxy sharedInstance] addObserverForNode:sourceNode];
}

@end
