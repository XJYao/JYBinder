//
//  JYBinderObjectWatcher.m
//  JYBinder
//
//  Created by XJY on 2018/5/7.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderObjectWatcher.h"

@implementation JYBinderObjectWatcher

- (void)dealloc {
    if (self.deallocBlock) {
        self.deallocBlock();
    }
}

@end
