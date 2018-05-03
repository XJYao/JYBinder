//
//  JYBinderChannel.h
//  JYBinder
//
//  Created by XJY on 2018/5/2.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JYBinderTerminal;

@interface JYBinderChannel : NSObject

@property (nonatomic, assign, readonly) BOOL isTwoWay;

@property (nonatomic, strong) JYBinderTerminal *leadingTerminal;

@property (nonatomic, strong) JYBinderTerminal *followingTerminal;

- (instancetype)initWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal twoWay:(BOOL)twoWay;

- (void)addObserver;

- (void)removeObserver;

@end
