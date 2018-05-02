//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderChannel.h"
#import "JYBinderTerminal.h"
//#import "JYBinderDefine.h"

//#define JYBinder(TARGET1, KEYPATH1, TARGET2, KEYPATH12)

#define JYBinderChannel(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[[JYBinderChannel alloc] initWithLeadingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET1 keyPath:@JYBinderKeypath(TARGET1, KEYPATH1)] followingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET2 keyPath:@JYBinderKeypath(TARGET2, KEYPATH2)]];

#define JYBinderKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

@interface JYBinder : NSObject


///**
// 单向绑定，1对多，不支持自定义赋值，必须保证属性类型一致
//
// @param sourceObject 源对象
// @param sourceKeyPath 源对象的被观察属性
// @param targetObject 目标对象及其属性
// */
//+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)targetObject, ... NS_REQUIRES_NIL_TERMINATION;
//
///**
// 单向绑定，1对1，支持自定义赋值
//
// @param sourceObject 源对象
// @param sourceKeyPath 源对象的被观察属性
// @param targetObject 目标对象
// @param targetKeyPath 目标对象的被关联属性
// @param block 如果为nil或返回YES，自动给目标对象的属性赋值（必须保证属性类型一致）；否则不会自动赋值，可以在block中手动给目标对象的属性赋值（不需要保证属性类型一致）
// */
//+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath targetObject:(id)targetObject targetKeyPath:(NSString *)targetKeyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block;
//
///**
// 解除绑定，将它从所有有关的绑定链中释放
//
// @param object 对象
// @param keyPath 属性
// */
//+ (void)unbindObject:(id)object keyPath:(NSString *)keyPath;
//
///**
// 解除指定关系链的绑定
//
// @param sourceObject 源对象
// @param sourceKeyPath 源对象属性
// @param targetObject 目标对象及其属性
// */
//+ (void)unbindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)targetObject, ... NS_REQUIRES_NIL_TERMINATION;

@end
