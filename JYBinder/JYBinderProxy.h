//
//  JYBinderProxy.h
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JYBinderNode;

@interface JYBinderProxy : NSObject

/**
 单例

 @return 监听器
 */
+ (instancetype)sharedInstance;

/**
 监听结点

 @param node 结点
 */
- (void)addObserverForNode:(JYBinderNode *)node;

/**
 移除指定结点的监听

 @param node 结点
 */
- (void)removeObserverForNode:(JYBinderNode *)node;

@end
