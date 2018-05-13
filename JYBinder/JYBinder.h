//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderTerminal.h"

/**
 生成单向绑定终端

 @param TARGET 对象
 @param KEYPATH 属性
 @return 终端
 */
#define JYBindToSingleWay(TARGET, KEYPATH) \
({ \
JYBinder *binder = [[JYBinder alloc] init]; \
[binder setValue:TARGET forKey:@"target"]; \
[binder setValue:@JYBinderKeypath(TARGET, KEYPATH) forKey:@"keyPath"]; \
[binder setValue:@(NO) forKey:@"isTwoWay"]; \
binder;\
})[nil]

/**
 生成双向绑定终端

 @param TARGET 对象
 @param KEYPATH 属性
 @return 终端
 */
#define JYBindToTwoWay(TARGET, KEYPATH) \
({ \
JYBinder *binder = [[JYBinder alloc] init]; \
[binder setValue:TARGET forKey:@"target"]; \
[binder setValue:@JYBinderKeypath(TARGET, KEYPATH) forKey:@"keyPath"]; \
[binder setValue:@(YES) forKey:@"isTwoWay"]; \
binder;\
})[nil]

/**
 将两终端解绑

 @param TARGET1 对象1
 @param KEYPATH1 属性1
 @param TARGET2 对象2
 @param KEYPATH2 属性2
 */
#define JYUnbind(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[JYBinder unbindWithTarget1:TARGET1 keyPath1:@JYBinderKeypath(TARGET1, KEYPATH1) target2:TARGET2 keyPath2:@JYBinderKeypath(TARGET2, KEYPATH2)]

@interface JYBinder : NSObject

/**
 将两终端做单向绑定

 @param leadingTerminal 主动更新的终端
 @param followingTerminal 被动更新的终端
 */
+ (void)bindToSingleWayWithLeading:(JYBinderTerminal *)leadingTerminal following:(JYBinderTerminal *)followingTerminal;

/**
 将两终端做双向绑定

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

#pragma mark - 私有方法，禁止直接调用

/**
 主要起到两个作用：1、代码自动补齐。 2、返回属性名字符串
 */
#define JYBinderKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

/**
 下标语法回调
 */
- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key;

@end
