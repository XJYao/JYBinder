//
//  Person.h
//  JYBinderDemo
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat weight;

@property (nonatomic, assign) NSInteger age;

@end
