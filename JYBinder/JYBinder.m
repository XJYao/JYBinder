//
//  JYBinder.m
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinder.h"
#import "JYBinderNode.h"
#import "JYBinderNodeManager.h"
#import "JYBinderProxy.h"
#import "JYBinderUtil.h"

@implementation JYBinder

+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)targetObject, ... {
    if ([JYBinderUtil isObjectNull:sourceObject] || [JYBinderUtil isStringEmpty:sourceKeyPath]) {
        return;
    }
    
    //取出所有参数
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    va_list args;
    va_start(args, targetObject);
    {
        NSUInteger paramIndex = 0;
        
        for (id otherObject = targetObject; ![JYBinderUtil isObjectNull:otherObject]; otherObject = va_arg(args, id)) {
            
            if (paramIndex % 2 == 0) {
                [objects addObject:otherObject];
            } else {
                [keyPaths addObject:otherObject];
            }
            
            paramIndex ++;
        }
    }
    va_end(args);
    
    //生成源结点
    JYBinderNode *sourceNode = [[JYBinderNodeManager sharedInstance] addNodeWithObject:sourceObject keyPath:sourceKeyPath willChangeTargetBlock:nil];
    //开启监听
    [[JYBinderProxy sharedInstance] addObserverForNode:sourceNode];
    
    //生成目标结点，并将它们与源结点关联
    for (NSInteger i = 0; i < objects.count; i ++) {
        id object = [objects objectAtIndex:i];
        id keyPath = nil;
        if (i < keyPaths.count) {
            keyPath = [keyPaths objectAtIndex:i];
        }
        if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
            continue;
        }
        JYBinderNode *targetNode = [[JYBinderNodeManager sharedInstance] addNodeWithObject:object keyPath:keyPath willChangeTargetBlock:nil];
        [sourceNode.bindingNodes addObject:targetNode];
    }
}

+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath targetObject:(id)targetObject targetKeyPath:(NSString *)targetKeyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block {
    if ([JYBinderUtil isObjectNull:sourceObject] || [JYBinderUtil isStringEmpty:sourceKeyPath] ||
        [JYBinderUtil isObjectNull:targetObject] || [JYBinderUtil isStringEmpty:targetKeyPath]) {
        return;
    }
    //生成源结点
    JYBinderNode *sourceNode = [[JYBinderNodeManager sharedInstance] addNodeWithObject:sourceObject keyPath:sourceKeyPath willChangeTargetBlock:nil];
    //开启属性监听
    [[JYBinderProxy sharedInstance] addObserverForNode:sourceNode];
    
    //生成目标结点，并将它与源结点关联
    JYBinderNode *targetNode = [[JYBinderNodeManager sharedInstance] addNodeWithObject:targetObject keyPath:targetKeyPath willChangeTargetBlock:block];
    [sourceNode.bindingNodes addObject:targetNode];
}

+ (void)unbindObject:(id)object keyPath:(NSString *)keyPath {
    //先取出结点
    JYBinderNode *node = [[JYBinderNodeManager sharedInstance] nodeWithObject:object keyPath:keyPath];
    if ([JYBinderUtil isObjectNull:node]) {
        return;
    }
    //移除监听
    [[JYBinderProxy sharedInstance] removeObserverForNode:node];
    //移除结点
    [[JYBinderNodeManager sharedInstance] removeNodeWithObject:object keyPath:keyPath];
}

+ (void)unbindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)targetObject, ... {
    //先取出源结点
    JYBinderNode *sourceNode = [[JYBinderNodeManager sharedInstance] nodeWithObject:sourceObject keyPath:sourceKeyPath];
    if ([JYBinderUtil isObjectNull:sourceNode]) {
        return;
    }
    
    //取出所有参数
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    va_list args;
    va_start(args, targetObject);
    {
        NSUInteger paramIndex = 0;
        
        for (id otherObject = targetObject; ![JYBinderUtil isObjectNull:otherObject]; otherObject = va_arg(args, id)) {
            
            if (paramIndex % 2 == 0) {
                [objects addObject:otherObject];
            } else {
                [keyPaths addObject:otherObject];
            }
            
            paramIndex ++;
        }
    }
    va_end(args);
    
    for (NSInteger i = 0; i < objects.count; i ++) {
        id object = [objects objectAtIndex:i];
        id keyPath = nil;
        if (i < keyPaths.count) {
            keyPath = [keyPaths objectAtIndex:i];
        }
        if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
            continue;
        }
        //取出目标结点
        JYBinderNode *targetNode = [[JYBinderNodeManager sharedInstance] nodeWithObject:object keyPath:keyPath];
        if ([JYBinderUtil isObjectNull:targetNode]) {
            continue;
        }
        [sourceNode.bindingNodes removeObject:targetNode];
    }
    
    if (sourceNode.bindingNodes.count == 0) {
        //移除监听
        [[JYBinderProxy sharedInstance] removeObserverForNode:sourceNode];
        //移除结点
        [[JYBinderNodeManager sharedInstance] removeNodeWithObject:sourceNode.object keyPath:sourceNode.keyPath];
    }
}

@end
