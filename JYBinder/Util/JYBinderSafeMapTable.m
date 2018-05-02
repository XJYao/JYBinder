//
//  JYBinderSafeMapTable.m
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderSafeMapTable.h"

@interface JYBinderSafeMapTable ()

/**
 线程锁
 */
@property (nonatomic, strong) NSLock *safeLock;

@property (nonatomic, strong) NSMapTable *mapTable;

@end

@implementation JYBinderSafeMapTable

- (instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions {
    self = [super init];
    if (self) {
        self.mapTable = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:0];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    [self.safeLock lock];
    [self.mapTable setObject:anObject forKey:aKey];
    [self.safeLock unlock];
}

- (id)objectForKey:(id)aKey {
    [self.safeLock lock];
    id object = [self.mapTable objectForKey:aKey];
    [self.safeLock unlock];
    return object;
}

- (void)removeObjectForKey:(id)aKey {
    [self.safeLock lock];
    [self.mapTable removeObjectForKey:aKey];
    [self.safeLock unlock];
}

- (void)removeAllObjects {
    [self.safeLock lock];
    [self.mapTable removeAllObjects];
    [self.safeLock unlock];
}

#pragma mark - lazy

- (NSLock *)safeLock {
    if (!_safeLock) {
        _safeLock = [[NSLock alloc] init];
    }
    return _safeLock;
}

@end
