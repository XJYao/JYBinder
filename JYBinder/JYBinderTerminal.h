//
//  JYBinderTerminal.h
//  JYBinder
//
//  Created by XJY on 2018/5/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderTerminal : NSObject

@property (nonatomic, weak, readonly) NSObject *target;

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonatomic, copy) id  _Nullable (^map)(id _Nullable value);

@property (nonatomic, weak) JYBinderTerminal *otherTerminal;

- (instancetype)initWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath;

@end
