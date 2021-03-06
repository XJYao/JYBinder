//
//  JYBinderTerminal.m
//  JYBinder
//
//  Created by XJY on 2018/3/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderTerminal.h"
#import "JYBinderUtil.h"

@interface JYBinderTerminal ()

@property (nonatomic, weak) NSObject *theTarget;

@property (nonatomic, copy) NSString *theKeyPath;

@end

@implementation JYBinderTerminal

+ (instancetype)terminalWithTarget:(NSObject *__weak)target keyPath:(NSString *)keyPath { 
    return [[JYBinderTerminal alloc] initWithTarget:target keyPath:keyPath];
}

- (instancetype)initWithTarget:(NSObject *__weak)target keyPath:(NSString *)keyPath {
    NSAssert(![JYBinderUtil isObjectNull:target], @"【JYBinder】: target为空");
    NSAssert(![JYBinderUtil isStringEmpty:keyPath], @"【JYBinder】: keyPath为空");
    
    self = [super init];
    if (self) {
        self.theTarget = target;
        self.theKeyPath = keyPath;
    }
    return self;
}

- (NSObject *)target {
    return self.theTarget;
}

- (NSString *)keyPath {
    return self.theKeyPath;
}

@end
