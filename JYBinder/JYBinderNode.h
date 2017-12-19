//
//  JYBinderNode.h
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderNode : NSObject

@property (nonatomic, weak, readonly) NSObject *object;

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonatomic, strong) NSSet<JYBinderNode *> *bindingNodes;

- (instancetype)initWithObject:(__weak NSObject *)object keyPath:(NSString *)keyPath;

@end
