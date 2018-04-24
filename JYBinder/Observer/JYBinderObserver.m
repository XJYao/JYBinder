//
//  JYBinderObserver.m
//  JYBinder
//
//  Created by XJY on 2017/12/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "JYBinderObserver.h"
#import "JYBinderUtil.h"
#import "NSObject+JYBinderDeallocating.h"
#import "JYBinderNode.h"
#import "JYBinderPropertyInfo.h"
#import <objc/message.h>

@implementation JYBinderObserver

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)addObserverForNode:(JYBinderNode *)node {
    if ([JYBinderUtil isObjectNull:node.object] || [JYBinderUtil isStringEmpty:node.keyPath]) {
        return;
    }
    
    //只监听未监听过的属性
    if ([node.object.registeredKeyPaths containsObject:node.keyPath]) {
        return;
    }
    
    void *context = (__bridge void * _Nullable)(node);
    
    //KVO监听
    [node.object addObserver:self forKeyPath:node.keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:context];
    //记录已监听的属性
    [node.object.registeredKeyPaths addObject:node.keyPath];
    
    __weak typeof(self) weak_self = self;
    
    node.object.removeObserverWhenDeallocBlock = ^(NSObject *deallocObject) {
        for (NSString *keyPath in deallocObject.registeredKeyPaths.allObjects) {
            [deallocObject removeObserver:weak_self forKeyPath:keyPath context:context];
        }
        [deallocObject.registeredKeyPaths removeAllObjects];
    };
}

- (void)removeObserverForNode:(JYBinderNode *)node {
    if ([JYBinderUtil isObjectNull:node.object] || [JYBinderUtil isStringEmpty:node.keyPath]) {
        return;
    }
    if ([node.object.registeredKeyPaths containsObject:node.keyPath]) {
        //已监听过，才移除
        [node.object removeObserver:self forKeyPath:node.keyPath context:(__bridge void * _Nullable)(node)];
        [node.object.registeredKeyPaths removeObject:node.keyPath];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    JYBinderNode *node = (__bridge JYBinderNode *)(context);
    if ([JYBinderUtil isObjectNull:node]) {
        return;
    }
    
    id value = [change objectForKey:NSKeyValueChangeNewKey];
    if ([JYBinderUtil isObjectNull:value]) {//value为空，直接置为nil，防止出错
        value = nil;
    }
    
    for (JYBinderNode *bindingNode in node.bindingNodes.allObjects) {
        if ([JYBinderUtil isObjectNull:bindingNode.object] ||
            [JYBinderUtil isStringEmpty:bindingNode.keyPath]) {
            continue;
        }
        BOOL autoChangeValue = YES;
        if (bindingNode.willChangeValueBlock) {
            autoChangeValue = bindingNode.willChangeValueBlock(value);
        }
        if (!autoChangeValue) {
            continue;
        }
        
        //赋值
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
            JYBinderPropertyInfo *propertyInfo = [[JYBinderPropertyInfo alloc] initWithProperty:property];
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

@end
