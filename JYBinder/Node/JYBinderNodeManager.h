//
//  JYBinderNodeManager.h
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderDefine.h"

@class JYBinderNode;

@interface JYBinderNodeManager : NSObject

/**
 单例

 @return 结点管理器
 */
+ (instancetype)sharedInstance;

/**
 获取结点

 @param object 对象
 @param keyPath 属性
 @return 返回nil表示当前不存在该结点。
 */
- (JYBinderNode *)nodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath;

/**
 添加结点，一对object和keyPath只能存在一个结点，如果表中存在该结点，则直接返回，否则创建。

 @param object 对象
 @param keyPath 属性
 @param block 值改变前的回调
 @return 生成结点
 */
- (JYBinderNode *)addNodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block;

/**
 移除结点

 @param object 对象
 @param keyPath 属性
 */
- (void)removeNodeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath;

/**
 移除结点
 
 @param object 对象
 */
- (void)removeNodeWithObject:(NSObject *__weak)object;

/**
 移除所有结点
 */
- (void)removeAllNodes;

@end
