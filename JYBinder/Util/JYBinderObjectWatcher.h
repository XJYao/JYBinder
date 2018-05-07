//
//  JYBinderObjectWatcher.h
//  JYBinder
//
//  Created by XJY on 2018/5/7.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderObjectWatcher : NSObject

@property (nonatomic, copy) void(^deallocBlock)(void);

@end
