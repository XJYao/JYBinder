//
//  JYBinderSafeHashTable.h
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderSafeHashTable : NSObject

@property (nonatomic, strong, readonly) NSArray *allObjects;

@property (nonatomic, assign, readonly) NSUInteger count;

- (void)addObject:(id)object;

- (void)removeObject:(id)object;

@end
