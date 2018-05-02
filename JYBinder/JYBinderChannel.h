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

- (instancetype)initWithLeadingTerminal:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

- (void)addObserver;

- (void)removeObserver;

@end

@interface JYBinderChannelsManager : NSObject

+ (instancetype)sharedInstance;

- (void)addChannel:(JYBinderChannel *)channel;

@end
