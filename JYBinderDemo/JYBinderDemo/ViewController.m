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

//解绑
//自定义setter时，需要实现setter方法并调用will和didchangevalue
//不支持char *


@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *name2Label;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@property (nonatomic, strong) Person *person1;
@property (nonatomic, strong) Person *person2;

@end

@implementation ViewController {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.nameTextField setDelegate:self];
    
    self.person1 = [[Person alloc] init];
    self.person2 = [[Person alloc] init];
    
    [JYBinder bindWithObjectsAndKeyPaths:
     self.person1, @"name",
     self.nameLabel, @"text",
     self.name2Label, @"text",
     nil];
    
    [JYBinder bindSourceObject:self.person2 sourceKeyPath:@"name" toObjectsAndKeyPaths:
     self.nameLabel, @"text",
     self.name2Label, @"text",
     nil];
    
    [self.person1 addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.person2 addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameLabel setText:textField.text];
    return YES;
}

- (IBAction)drop:(id)sender {
    [self.person1 setName:@"tom"];
//    [self.person1 removeObserver:self forKeyPath:@"name"];
//    self.person1 = nil;
}

- (IBAction)drop2:(id)sender {
    [self.person2 setName:@"nick"];
//    [self.person2 removeObserver:self forKeyPath:@"name"];
//    self.person2  = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.person1) {
        [self.button1 setTitle:self.person1.name forState:UIControlStateNormal];
    } else if (object == self.person2) {
        [self.button2 setTitle:self.person2.name forState:UIControlStateNormal];
    }
}

@end
