//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBinderChannel.h"
#import "JYBinderTerminal.h"
#import "JYBinderChannelManager.h"

#define JYBind(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initWithLeadingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET1 keyPath:@JYBinderKeypath(TARGET1, KEYPATH1)] followingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET2 keyPath:@JYBinderKeypath(TARGET2, KEYPATH2)] twoWay:NO]];

#define JYBindChannel(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[[JYBinderChannelManager sharedInstance] addChannel:[[JYBinderChannel alloc] initWithLeadingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET1 keyPath:@JYBinderKeypath(TARGET1, KEYPATH1)] followingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET2 keyPath:@JYBinderKeypath(TARGET2, KEYPATH2)] twoWay:YES]];

#define JYUnbind(TARGET1, KEYPATH1, TARGET2, KEYPATH2) \
[[JYBinderChannelManager sharedInstance] removeChannel:[[JYBinderChannel alloc] initWithLeadingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET1 keyPath:@JYBinderKeypath(TARGET1, KEYPATH1)] followingTerminal:[[JYBinderTerminal alloc] initWithTarget:TARGET2 keyPath:@JYBinderKeypath(TARGET2, KEYPATH2)] twoWay:NO]];

#define JYBinderKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

@interface JYBinder : NSObject


@end
