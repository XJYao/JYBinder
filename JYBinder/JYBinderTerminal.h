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
 关联的终端
 */
@property (nonatomic, weak) JYBinderTerminal *otherTerminal;

/**
 初始化
 */
- (instancetype)initWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath;

@end
