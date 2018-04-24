//
//  JYBinderSafeMapTable.h
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 线程安全
 */
@interface JYBinderSafeMapTable : NSObject

- (void)setObject:(id)anObject forKey:(id)aKey;

- (id)objectForKey:(id)aKey;

- (void)removeObjectForKey:(id)aKey;

- (void)removeAllObjects;

@end
