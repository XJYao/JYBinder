//
//  JYBinderUtil.h
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBinderUtil : NSObject

+ (BOOL)isObjectNull:(id)obj;

+ (BOOL)isStringEmpty:(NSString *)str;

+ (BOOL)isEqualFromString:(NSString *)fromString toString:(NSString *)toString;

@end
