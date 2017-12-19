//
//  NSObject+JYBinderDeallocating.h
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JYBinderDeallocating)

- (void)deallocDisposable:(void (^)(id deallocObject))block;

@end
