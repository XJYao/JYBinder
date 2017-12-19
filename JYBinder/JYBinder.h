//
//  JYBinder.h
//  JYBinder
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinder : NSObject

+ (void)bindWithObjectsAndKeyPaths:(id)object1, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)bindSourceObject:(id)sourceObject sourceKeyPath:(NSString *)sourceKeyPath toObjectsAndKeyPaths:(id)object1, ... NS_REQUIRES_NIL_TERMINATION;

@end
