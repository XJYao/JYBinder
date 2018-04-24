//
//  JYBinderNode.h
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderDefine.h"
#import "JYBinderSafeHashTable.h"

@interface JYBinderNode : NSObject

/**
 对象
 */
@property (nonatomic, weak, readonly) NSObject *object;

/**
 属性
 */
@property (nonatomic, copy, readonly) NSString *keyPath;

/**
 关联的结点，表中元素都是弱引用
 */
@property (nonatomic, strong, readonly) JYBinderSafeHashTable *bindingNodes;

/**
 值改变前的回调
 */
@property (nonatomic, copy) JYBinderNodeWillChangeValueBlock willChangeValueBlock;

/**
 初始化方法，弱引用对象
 */
- (instancetype)initWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block;

@end
