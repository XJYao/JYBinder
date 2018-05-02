//
//  NSObject+JYBinderDeallocating.h
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderSafeMutableSet.h"

@interface NSObject (JYBinderDeallocating)

/**
 已监听过的属性
 */
//@property (nonatomic, strong) JYBinderSafeMutableSet *registeredKeyPaths;

/**
 对象释放时的回调
 */
- (void)addRemoveObserverWhenDeallocBlock:(void (^)(NSObject *deallocObject))block;

@end
