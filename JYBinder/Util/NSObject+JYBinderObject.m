//
//  NSObject+JYBinderObject.m
//  JYBinder
//
//  Created by XJY on 2018/5/7.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "NSObject+JYBinderObject.h"
#import <objc/runtime.h>
#import "JYBinderObjectWatcher.h"
#import "JYBinderUtil.h"

@implementation NSObject (JYBinderObject)

void *kJYBinderObjectWatcher = &kJYBinderObjectWatcher;

- (void)observerDealloc:(void (^)(void))deallocBlock {
    JYBinderObjectWatcher *watcher = objc_getAssociatedObject(self, kJYBinderObjectWatcher);
    if (![JYBinderUtil isObjectNull:watcher] && [watcher isKindOfClass:[JYBinderObjectWatcher class]]) {
        watcher.deallocBlock = deallocBlock;
        return;
    }
    
    watcher = [[JYBinderObjectWatcher alloc] init];
    watcher.deallocBlock = deallocBlock;
    objc_setAssociatedObject(self, kJYBinderObjectWatcher, watcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
