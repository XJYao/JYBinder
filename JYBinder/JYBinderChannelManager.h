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

/**
 通道管理者，单例
 */
+ (instancetype)sharedInstance;

/**
 添加通道

 @param channel 通道
 */
- (void)addChannel:(JYBinderChannel *)channel;

/**
 移除通道

 @param channel 通道
 */
- (void)removeChannel:(JYBinderChannel *)channel;

@end
