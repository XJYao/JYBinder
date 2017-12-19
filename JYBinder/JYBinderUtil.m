//
//  JYBinderUtil.m
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderUtil.h"

@implementation JYBinderUtil

+ (BOOL)isObjectNull:(id)obj {
    if (!obj || obj == nil || obj == Nil || obj == NULL || [obj isEqual:[NSNull null]] || obj == (id)kCFNull) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isStringEmpty:(NSString *)str {
    if ([self isObjectNull:str]) {
        return YES;
    }
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    return str.length == 0;
}

+ (BOOL)isEqualFromString:(NSString *)fromString toString:(NSString *)toString {
    BOOL isFromStringEmpty = [self isStringEmpty:fromString];
    BOOL isToStringEmpty = [self isStringEmpty:toString];
    if (!isFromStringEmpty && !isToStringEmpty) {
        return [fromString isEqualToString:toString];
    } else {
        if (isFromStringEmpty && isToStringEmpty) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
