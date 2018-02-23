//
//  NSObject+JYBinderDeallocating.h
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JYBinderDeallocating)

@property (nonatomic, strong) NSMutableSet *registeredKeyPaths;

- (void)removeObserverWhenDealloc:(NSObject *)observer;

@end
