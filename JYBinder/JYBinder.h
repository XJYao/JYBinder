//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderTerminal.h"
#import "JYBinderGenerator.h"

/**
 生成单向绑定终端

 @param TARGET 对象
 @param KEYPATH 属性
 @return 终端
 */
#define JYBindToSingleWay(TARGET, KEYPATH) \
[[JYBinderGenerator alloc] initWithTarget:TARGET keyPath:@JYBinderKeypath(TARGET, KEYPATH) isTwoWay:NO][JYBinderKey]

/**
 生成双向绑定终端

 @param TARGET 对象
 @param KEYPATH 属性
 @return 终端
 */
#define JYBindToTwoWay(TARGET, KEYPATH) \
[[JYBinderGenerator alloc] initWithTarget:TARGET keyPath:@JYBinderKeypath(TARGET, KEYPATH) isTwoWay:YES][JYBinderKey]

/**
 将两终端解绑

 @param TARGET1 对象1
 @param KEYPATH1 属性1
 @param TARGET2 对象2
 @param KEYPATH2 属性2
 */
#define JYUnbind(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[JYBinderGenerator unbindWithTarget1:TARGET1 keyPath1:@JYBinderKeypath(TARGET1, KEYPATH1) target2:TARGET2 keyPath2:@JYBinderKeypath(TARGET2, KEYPATH2)]

@interface JYBinder : NSObject

/**
 将两终端做单向绑定

 @param leadingTerminal 监听者
 @param followingTerminal 跟随者
 */
+ (void)bindToSingleWayWithLeading:(JYBinderTerminal *)leadingTerminal following:(JYBinderTerminal *)followingTerminal;

/**
 将两终端做双向绑定，互相监听跟随

 @param terminal 终端
 @param otherTerminal 另一个终端
 */
+ (void)bindToTwoWayWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal;

/**
 将两终端解绑

 @param terminal 终端
 @param otherTerminal 另一个终端
 */
+ (void)unbindWithOneTerminal:(JYBinderTerminal *)terminal otherTerminal:(JYBinderTerminal *)otherTerminal;

/**
 将两终端解绑
 
 @param target1 对象1
 @param keyPath1 属性1
 @param target2 对象2
 @param keyPath2 属性2
 */
+ (void)unbindWithTarget1:(__weak NSObject *)target1 keyPath1:(NSString *)keyPath1 target2:(__weak NSObject *)target2 keyPath2:(NSString *)keyPath2;

@end
