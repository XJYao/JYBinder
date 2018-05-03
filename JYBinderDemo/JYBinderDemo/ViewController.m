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
    
    JYBind(self.person, name, self.label1, text);
    JYBindChannel(self.label1, text, self.label2, text);
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

@end
