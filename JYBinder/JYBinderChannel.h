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

@property (nonatomic, strong, readonly) JYBinderTerminal *leadingTerminal;

@property (nonatomic, strong, readonly) JYBinderTerminal *followingTerminal;

- (instancetype)initSingleWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

- (instancetype)initTwoWayWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

- (void)addObserver;

- (void)removeObserver;

@end
