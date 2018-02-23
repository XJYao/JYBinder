//
//  JYBinderNode.m
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderNode.h"
#import <objc/message.h>
#import "JYBinderUtil.h"
#import <JYLibrary/JYLibrary.h>

@interface JYBinderNode ()

@end

@implementation JYBinderNode

- (instancetype)initWithObject:(NSObject *__weak)object keyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = keyPath;
        _bindingNodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != self.object) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    id old = [change objectForKey:NSKeyValueChangeOldKey];
    id new = [change objectForKey:NSKeyValueChangeNewKey];
    
    BOOL isOldNull = [JYBinderUtil isObjectNull:old];
    BOOL isNewNull = [JYBinderUtil isObjectNull:new];
    
    if (isOldNull && isNewNull) {
        return;
    }

    if (!isOldNull && !isNewNull) {
        if (old == new) {
            return;
        }
        if ([old isKindOfClass:[new class]]) {
            if ([old isKindOfClass:[NSString class]]) {
                if ([JYBinderUtil isEqualFromString:old toString:new]) {
                    return;
                }
            } else if ([old isKindOfClass:[NSNumber class]]) {
                if ([JYBinderUtil isEqualFromString:[old stringValue] toString:[new stringValue]]) {
                    return;
                }
            }
        }
    }
    
    id value = new;
    
    @synchronized (self) {
        for (JYBinderNode *bindingNode in self.bindingNodes) {
            if ([JYBinderUtil isObjectNull:bindingNode.object] ||
                [JYBinderUtil isStringEmpty:bindingNode.keyPath]) {
                continue;
            }
            
            unsigned int propertiesCount = 0;
            objc_property_t *properties = class_copyPropertyList([bindingNode.object class], &propertiesCount);
            
            if (!properties || propertiesCount == 0) {
                if (properties) {
                    free(properties);
                }
                continue;
            }
            
            char *type = NULL;
            SEL setter = NULL;
            
            for (int i = 0; i < propertiesCount; i++) {
                objc_property_t property = properties[i];
                XPropertyInfo *propertyInfo = [[XPropertyInfo alloc] initWithProperty:property];
                if (![JYBinderUtil isEqualFromString:propertyInfo.name toString:bindingNode.keyPath]) {
                    continue;
                }
                type = (char *)[propertyInfo.typeEncoding UTF8String];
                setter = propertyInfo.setter;
                break;
            }
            
            if (properties) {
                free(properties);
            }
            
            if (!type || !setter) {
                continue;
            }
            
            switch (*type) {
                case _C_ID: {//@
                    ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)bindingNode.object, setter, value);
                } break;
                    
                case _C_CHR: { //char
                    ((void (*)(id, SEL, char))(void *)objc_msgSend)((id)bindingNode.object, setter, [value charValue]);
                } break;
                    
                case _C_INT: { //int32
                    ((void (*)(id, SEL, int))(void *)objc_msgSend)((id)bindingNode.object, setter, [value intValue]);
                } break;
                    
                case _C_SHT: { //short
                    ((void (*)(id, SEL, short))(void *)objc_msgSend)((id)bindingNode.object, setter, [value shortValue]);
                } break;
                    
                case _C_LNG: { //long
                    ((void (*)(id, SEL, long))(void *)objc_msgSend)((id)bindingNode.object, setter, [value longValue]);
                } break;
                    
                case _C_LNG_LNG: { //long long / int64
                    ((void (*)(id, SEL, NSInteger))(void *)objc_msgSend)((id)bindingNode.object, setter, [value integerValue]);
                } break;
                    
                case _C_UCHR: { //unsigned char / unsigned int8
                    ((void (*)(id, SEL, unsigned char))(void *)objc_msgSend)((id)bindingNode.object, setter, [value unsignedCharValue]);
                } break;
                    
                case _C_UINT: { //unsigned int
                    ((void (*)(id, SEL, unsigned int))(void *)objc_msgSend)((id)bindingNode.object, setter, [value unsignedIntValue]);
                } break;
                    
                case _C_USHT: { //unsigned short
                    ((void (*)(id, SEL, unsigned short))(void *)objc_msgSend)((id)bindingNode.object, setter, [value unsignedShortValue]);
                } break;
                    
                case _C_ULNG: { //unsigned long
                    ((void (*)(id, SEL, unsigned long))(void *)objc_msgSend)((id)bindingNode.object, setter, [value unsignedLongValue]);
                } break;
                    
                case _C_ULNG_LNG: { //unsigned long long / unsigned int64
                    ((void (*)(id, SEL, NSUInteger))(void *)objc_msgSend)((id)bindingNode.object, setter, [value unsignedIntegerValue]);
                } break;
                    
                case _C_FLT: { //float
                    ((void (*)(id, SEL, float))(void *)objc_msgSend)((id)bindingNode.object, setter, [value floatValue]);
                } break;
                    
                case _C_DBL: { //double
                    ((void (*)(id, SEL, double))(void *)objc_msgSend)((id)bindingNode.object, setter, [value doubleValue]);
                } break;
                    
                case 'D': { //long double
                    ((void (*)(id, SEL, CGFloat))(void *)objc_msgSend)((id)bindingNode.object, setter, [value floatValue]);
                } break;
                    
                case _C_BFLD : {
                    ((void (*)(id, SEL, BOOL))(void *)objc_msgSend)((id)bindingNode.object, setter, [value boolValue]);
                } break;
                    
                case _C_BOOL: { //a C++ bool or a C99 _Bool
                    ((void (*)(id, SEL, BOOL))(void *)objc_msgSend)((id)bindingNode.object, setter, [value boolValue]);
                } break;
                default: {
                    ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)bindingNode.object, setter, value);
                } break;
            }
        }
    }
}

@end
