//
//  JYBinderSafeMutableSet.h
//  JYBinder
//
//  Created by JY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 线程安全
 */
@interface JYBinderSafeMutableSet : NSObject

@property (nonatomic, strong, readonly) NSArray *allObjects;

- (void)addObject:(id)object;

- (void)removeObject:(id)object;

- (void)removeAllObjects;

- (BOOL)containsObject:(id)anObject;

@end
