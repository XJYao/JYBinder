//
//  JYBinderChannel.h
//  JYBinder
//
//  Created by XJY on 2018/3/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JYBinderTerminal;

@interface JYBinderChannel : NSObject

/**
 是否双向
 */
@property (nonatomic, assign) BOOL isTwoWay;

/**
 监听者
 */
@property (nonatomic, strong) JYBinderTerminal *leadingTerminal;

/**
 跟随者
 */
@property (nonatomic, strong) JYBinderTerminal *followingTerminal;

/**
 初始化单向通道
 */
- (instancetype)initSingleWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

/**
 初始化双向通道
 */
- (instancetype)initTwoWayWithOneTerminal:(JYBinderTerminal *)oneTerminal otherTerminal:(JYBinderTerminal *)otherTerminal;

/**
 添加监听
 */
- (void)addObserver;

/**
 移除监听
 */
- (void)removeObserver;

@end
