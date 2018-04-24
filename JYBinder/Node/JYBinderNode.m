//
//  JYBinderNode.m
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderNode.h"

@implementation JYBinderNode

- (instancetype)initWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath willChangeTargetBlock:(JYBinderNodeWillChangeValueBlock)block {
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = keyPath;
        _willChangeValueBlock = block;
        _bindingNodes = [[JYBinderSafeHashTable alloc] init];
    }
    return self;
}

@end
