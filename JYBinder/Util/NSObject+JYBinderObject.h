//
//  NSObject+JYBinderObject.h
//  JYBinder
//
//  Created by XJY on 2018/5/7.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JYBinderObject)

/**
 监听对象被释放

 @param deallocBlock 被释放时进入该回调
 */
- (void)observerDealloc:(void (^)(void))deallocBlock;

@end
