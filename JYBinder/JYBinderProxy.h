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

+ (instancetype)sharedInstance;

- (void)addObserverForNode:(JYBinderNode *)node;

- (void)addBindedNode:(JYBinderNode *)node;

//- (void)removeObserverForObject:(NSObject *)object keyPath:(NSString *)keyPath;
//
//- (void)removeObserversForObject:(NSObject *)object;

@end
