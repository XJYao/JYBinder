//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderTerminal.h"
#import "JYBinderChannel.h"
#import "JYBinderChannelManager.h"

#pragma mark - public macro

#define JYBindSingleWayChannel(TARGET, KEYPATH) \
[[JYBinder alloc] initWithTarget:TARGET keyPath:@JYBinderKeypath(TARGET, KEYPATH) isTwoWay:NO][@JYBinderKeypath(TARGET, KEYPATH)]

#define JYBindTwoWayChannel(TARGET, KEYPATH) \
[[JYBinder alloc] initWithTarget:TARGET keyPath:@JYBinderKeypath(TARGET, KEYPATH) isTwoWay:YES][@JYBinderKeypath(TARGET, KEYPATH)]

#define JYUnbind(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[[JYBinderChannelManager sharedInstance] removeChannel:[[JYBinderChannel alloc] initSingleWayWithLeadingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET1 keyPath:@JYBinderKeypath(TARGET1, KEYPATH1)] followingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET2 keyPath:@JYBinderKeypath(TARGET2, KEYPATH2)]]];

#pragma mark - private macro

#define JYBinderKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

@interface JYBinder : NSObject

#pragma mark - public

+ (void)bindToSingleWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

+ (void)bindToTwoWayChannel:(JYBinderTerminal *)leadingTerminal followingTerminal:(JYBinderTerminal *)followingTerminal;

#pragma mark - private

- (instancetype)initWithTarget:(__weak NSObject *)target keyPath:(NSString *)keyPath isTwoWay:(BOOL)isTwoWay;

- (JYBinderTerminal *)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(JYBinderTerminal *)leadingTerminal forKeyedSubscript:(NSString *)key;

@end
