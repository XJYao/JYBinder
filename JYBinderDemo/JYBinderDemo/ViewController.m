//
//  ViewController.m
//  JYBinderDemo
//
//  Created by XJY on 2017/12/15.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <JYBinder/JYBinder.h>

#import <ReactiveObjC/ReactiveObjC.h>

//自定义setter时，需要实现setter方法并调用will和didchangevalue


@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person = [[Person alloc] init];
    
    JYBinderChannel(self.label1, text, self.person, name);
    JYBinderChannel(self.label1, text, self.label2, text);
//    RACChannelTo(self.label1, text) = RACChannelTo(self.person, name);
    
//    [JYBinder bindSourceObject:self.person sourceKeyPath:@"name" toObjectsAndKeyPaths:self.label1, @"text", self.label2, @"text", nil];
    
//    [JYBinder bindSourceObject:self.person sourceKeyPath:@"name" targetObject:self.label1 targetKeyPath:@"text" willChangeTargetBlock:^BOOL(id sourceValue) {
//        return YES;
//    }];
//
//    [JYBinder bindSourceObject:self.label1 sourceKeyPath:@"text" targetObject:self.label2 targetKeyPath:@"text" willChangeTargetBlock:^BOOL(id sourceValue) {
//        return YES;
//    }];
//
//    [JYBinder bindSourceObject:self.label2 sourceKeyPath:@"text" targetObject:self.label3 targetKeyPath:@"text" willChangeTargetBlock:^BOOL(id sourceValue) {
//        return YES;
//    }];
    
//    [JYBinder bindSourceObject:self.label3 sourceKeyPath:@"text" targetObject:self.person targetKeyPath:@"name" willChangeTargetBlock:^BOOL(id sourceValue) {
//        return YES;
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)click1:(id)sender {
    [self.person setName:self.person.name.length > 0 ? [self.person.name stringByAppendingString:@"1"] : @"1"];
}

- (IBAction)click2:(id)sender {
    self.label1.text = @"aa";
//    [JYBinder unbindObject:self.person keyPath:@"name"];
//    [JYBinder unbindSourceObject:self.person sourceKeyPath:@"name" toObjectsAndKeyPaths:self.label1, @"text", nil];
}

@end
