//
//  aaaaa.m
//  JYBinderDemo
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "aaaaa.h"

@implementation aaaaa {
    void(^_block)(void);
}

- (instancetype)initWithDeallocBlock:(void (^)(void))block
{
    
    
    self
    = [super
       init];
    
    
    if
        (self)
    {
        
        
        self->_block
        = [block copy];
        
        
    }
    
    
    return
    self;
    
    
}


- (void)dealloc
{
    
    
    if
        (self->_block)
    {
        
        
        self->_block();
        
        
    }
    
    
}

@end
