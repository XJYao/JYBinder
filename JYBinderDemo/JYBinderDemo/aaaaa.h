//
//  aaaaa.h
//  JYBinderDemo
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface aaaaa : NSObject

@property (nonatomic, assign) int cccc;
- (instancetype)initWithDeallocBlock:(void (^)(void))block;

@end
