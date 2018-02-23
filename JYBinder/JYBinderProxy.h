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

- (JYBinderNode *)addObserverForObject:(NSObject *__weak)object keyPath:(NSString *)keyPath;

- (JYBinderNode *)addBindedWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath;

- (void)removeWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath;

- (void)removeWithObject:(NSObject *__weak)object;

@end
