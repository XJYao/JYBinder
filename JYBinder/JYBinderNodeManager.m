//
//  JYBinderNodeManager.m
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderNodeManager.h"
#import "JYBinderUtil.h"
#import "JYBinderSafeMapTable.h"
#import "JYBinderNode.h"

@interface JYBinderNodeManager ()

/**
 以object->keyPath->node的结构来保存管理结点，其中object为weak，保证它被释放时，自动移除与其相关的结点。
 */
@property (nonatomic, strong) JYBinderSafeMapTable/* object, NSDictionary *<keyPath, node> */ *nodeMapTable;

@end

@implementation JYBinderNodeManager

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (JYBinderNode *)nodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return nil;
    }
    NSMutableDictionary *nodeForKeyPathDict = [self.nodeMapTable objectForKey:object];
    return [nodeForKeyPathDict objectForKey:keyPath];
}

- (JYBinderNode *)addNodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return nil;
    }
    //先从表中找是否存在该结点
    NSMutableDictionary *nodeForKeyPathDict = [self.nodeMapTable objectForKey:object];
    if ([JYBinderUtil isObjectNull:nodeForKeyPathDict]) {
        nodeForKeyPathDict = [NSMutableDictionary dictionary];
        [self.nodeMapTable setObject:nodeForKeyPathDict forKey:object];
    }
    JYBinderNode *oldNode = [nodeForKeyPathDict objectForKey:keyPath];
    //不存在，就创建一个
    if ([JYBinderUtil isObjectNull:oldNode]) {
        oldNode = [[JYBinderNode alloc] initWithObject:object keyPath:keyPath willChangeTargetBlock:block];
        
        [nodeForKeyPathDict setObject:oldNode forKey:keyPath];
    }
    
    return oldNode;
}

- (void)removeNodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath {
    if ([JYBinderUtil isObjectNull:object] || [JYBinderUtil isStringEmpty:keyPath]) {
        return;
    }
    
    NSMutableDictionary *nodeForKeyPathDict = [self.nodeMapTable objectForKey:object];
    [nodeForKeyPathDict removeObjectForKey:keyPath];
}

- (void)removeNodeWithObject:(NSObject *__weak)object {
    if ([JYBinderUtil isObjectNull:object]) {
        return;
    }
    [self.nodeMapTable removeObjectForKey:object];
}

- (void)removeAllNodes {
    [self.nodeMapTable removeAllObjects];
}

#pragma mark - lazy

- (JYBinderSafeMapTable *)nodeMapTable {
    if (!_nodeMapTable) {
        _nodeMapTable = [[JYBinderSafeMapTable alloc] init];
    }
    return _nodeMapTable;
}

@end
