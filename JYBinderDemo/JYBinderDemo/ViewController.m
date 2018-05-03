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

    //单向绑定person name 和label1
    JYBindSingleWayChannel(self.label1, text) = JYBindSingleWayChannel(self.person, name);
    
    //双向绑定label1 和 label2
    JYBindTwoWayChannel(self.label1, text) = JYBindTwoWayChannel(self.label2, text);
    
    //单向绑定person age和label3
    JYBinderTerminal *followingTerminal = JYBindSingleWayChannel(self.label3, text);

    followingTerminal.map = ^id _Nullable(id  _Nullable value) {
        //自定义转换
        return [value stringValue];
    };
    JYBinderTerminal *leadingTerminal = JYBindSingleWayChannel(self.person, age);
    [JYBinder bindToSingleWayChannel:leadingTerminal followingTerminal:followingTerminal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)click1:(id)sender {
    [self.person setName:self.person.name.length > 0 ? [self.person.name stringByAppendingString:@"1"] : @"1"];
}

- (IBAction)click2:(id)sender {
    JYUnbind(self.person, name, self.label1, text);
}

- (IBAction)click3:(id)sender {
    [self.label2 setText:self.label2.text.length > 0 ? [self.label2.text stringByAppendingString:@"2"] : @"2"];
}

- (IBAction)click4:(id)sender {
    self.person.age ++;
}

- (IBAction)click5:(id)sender {
    JYUnbind(self.label1, text, self.label2, text);
}

@end
