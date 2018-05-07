//
//  JYBinderGenerator.h
//  JYBinder
//
//  Created by XJY on 2018/3/3.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

//主要起到两个作用：1、代码自动补齐。 2、返回属性名字符串
#define JYBinderKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

@class JYBinderTerminal;

/**
 为了避免JYBinder类暴露太多不必要的接口，所以创建此类来做一个中转
 */
@interface JYBinderGenerator : NSObject

/**
 初始化生成器

 @param target 对象
 @param keyPath 属性
 @param isTwoWay 是否双向
 @return 生成器
 */
- (instancetype)initWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath isTwoWay:(BOOL)isTwoWay;

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

/**
 下标语法回调
 */
- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key;

@end
