//
//  JYBinderTerminal.h
//  JYBinder
//
//  Created by XJY on 2018/3/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderTerminal : NSObject

/**
 对象
 */
@property (nonatomic, weak, readonly) NSObject * _Nullable target;

/**
 属性
 */
@property (nonatomic, copy, readonly) NSString * _Nullable keyPath;

/**
 自定义转换值
 */
@property (nonatomic, copy) id _Nullable (^ _Nonnull map)(id _Nullable value);

/**
 指定线程中赋值
 */
@property (nonatomic, strong) dispatch_queue_t _Nullable queue;

/**
 初始化
 */
+ (instancetype _Nonnull)terminalWithTarget:(__weak NSObject *_Nullable)target keyPath:(NSString *_Nullable)keyPath;

- (instancetype _Nonnull)initWithTarget:(__weak NSObject *_Nullable)target keyPath:(NSString *_Nullable)keyPath;

@end
