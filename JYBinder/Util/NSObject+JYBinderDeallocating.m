//
//  NSObject+JYBinderDeallocating.m
//  JYBinder
//
//  Created by XJY on 2017/12/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "NSObject+JYBinderDeallocating.h"
#import "JYBinderUtil.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface NSObject ()

@property (nonatomic, strong) NSMutableSet *blocks;

@end

@implementation NSObject (JYBinderDeallocating)

typedef void (^JYBinderRemoveObserverWhenDeallocBlock)(NSObject *deallocObject);

static NSMutableSet *swizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    return swizzledClasses;
}

static void swizzleDeallocIfNeeded(Class classToSwizzle) {
    @synchronized (swizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([swizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            for (JYBinderRemoveObserverWhenDeallocBlock block in ((NSObject *)self).blocks) {
                block(self);
            }
            
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [swizzledClasses() addObject:className];
    }
}

- (void)addRemoveObserverWhenDeallocBlock:(void (^)(NSObject *))block {
    if ([JYBinderUtil isObjectNull:block]) {
        return;
    }
    [self.blocks addObject:block];
    swizzleDeallocIfNeeded(self.class);
}

//static const void *RegisteredKeyPathsKey = &RegisteredKeyPathsKey;
//
//- (void)setRegisteredKeyPaths:(JYBinderSafeMutableSet *)registeredKeyPaths {
//    objc_setAssociatedObject(self, RegisteredKeyPathsKey, registeredKeyPaths, OBJC_ASSOCIATION_RETAIN);
//}
//
//- (JYBinderSafeMutableSet *)registeredKeyPaths {
//    JYBinderSafeMutableSet *obj = objc_getAssociatedObject(self, RegisteredKeyPathsKey);
//    if ([JYBinderUtil isObjectNull:obj]) {
//        obj = [[JYBinderSafeMutableSet alloc] init];
//        [self setRegisteredKeyPaths:obj];
//    }
//    return obj;
//}

static const void *RemoveObserverWhenDeallocBlocksKey = &RemoveObserverWhenDeallocBlocksKey;

- (void)setBlocks:(NSMutableSet *)blocks {
    @synchronized (self) {
        objc_setAssociatedObject(self, RemoveObserverWhenDeallocBlocksKey, blocks, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSMutableSet *)blocks {
    return objc_getAssociatedObject(self, RemoveObserverWhenDeallocBlocksKey);
}

@end
