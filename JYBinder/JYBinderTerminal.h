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
@property (nonatomic, weak, readonly) NSObject *target;

/**
 属性
 */
@property (nonatomic, copy, readonly) NSString *keyPath;

/**
 自定义转换值
 */
@property (nonatomic, copy) id  _Nullable (^map)(id _Nullable value);

/**
 指定线程中赋值
 */
@property (nonatomic, strong) dispatch_queue_t queue;

/**
 初始化
 */
+ (instancetype)terminalWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath;

- (instancetype)initWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath;

@end
