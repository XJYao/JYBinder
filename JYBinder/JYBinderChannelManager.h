//
//  JYBinderChannelManager.h
//  JYBinder
//
//  Created by XJY on 2018/5/3.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JYBinderChannel;

@interface JYBinderChannelManager : NSObject

+ (instancetype)sharedInstance;

- (void)addChannel:(JYBinderChannel *)channel;

- (void)removeChannel:(JYBinderChannel *)channel;

@end
