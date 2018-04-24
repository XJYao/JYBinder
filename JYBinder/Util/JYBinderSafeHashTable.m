//
//  JYBinderSafeHashTable.m
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderSafeHashTable.h"

@interface JYBinderSafeHashTable ()

/**
 线程锁
 */
@property (nonatomic, strong) NSLock *safeLock;

@property (nonatomic, strong) NSHashTable *hashTable;

@end

@implementation JYBinderSafeHashTable

- (NSArray *)allObjects {
    [self.safeLock lock];
    NSArray *allObjects = self.hashTable.allObjects;
    [self.safeLock unlock];
    return allObjects;
}

- (NSUInteger)count {
    [self.safeLock lock];
    NSUInteger count = self.hashTable.count;
    [self.safeLock unlock];
    return count;
}

- (void)addObject:(id)object {
    [self.safeLock lock];
    [self.hashTable addObject:object];
    [self.safeLock unlock];
}

- (void)removeObject:(id)object {
    [self.safeLock lock];
    [self.hashTable removeObject:object];
    [self.safeLock unlock];
}

#pragma mark - lazy

- (NSLock *)safeLock {
    if (!_safeLock) {
        _safeLock = [[NSLock alloc] init];
    }
    return _safeLock;
}

- (NSHashTable *)hashTable {
    if (!_hashTable) {
        _hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _hashTable;
}

@end
