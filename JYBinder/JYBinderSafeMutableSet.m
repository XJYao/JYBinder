//
//  JYBinderSafeMutableSet.m
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderSafeMutableSet.h"

@interface JYBinderSafeMutableSet ()

/**
 线程锁
 */
@property (nonatomic, strong) NSLock *safeLock;

@property (nonatomic, strong) NSMutableSet *mutableSet;

@end

@implementation JYBinderSafeMutableSet

- (NSArray *)allObjects {
    [self.safeLock lock];
    NSArray *allObjects = self.mutableSet.allObjects;
    [self.safeLock unlock];
    return allObjects;
}

- (void)addObject:(id)object {
    [self.safeLock lock];
    [self.mutableSet addObject:object];
    [self.safeLock unlock];
}

- (void)removeObject:(id)object {
    [self.safeLock lock];
    [self.mutableSet removeObject:object];
    [self.safeLock unlock];
}

- (void)removeAllObjects {
    [self.safeLock lock];
    [self.mutableSet removeAllObjects];
    [self.safeLock unlock];
}

- (BOOL)containsObject:(id)anObject {
    [self.safeLock lock];
    BOOL contains = [self.mutableSet containsObject:anObject];
    [self.safeLock unlock];
    return contains;
}

#pragma mark - lazy

- (NSLock *)safeLock {
    if (!_safeLock) {
        _safeLock = [[NSLock alloc] init];
    }
    return _safeLock;
}

- (NSMutableSet *)mutableSet {
    if (!_mutableSet) {
        _mutableSet = [NSMutableSet set];
    }
    return _mutableSet;
}

@end
