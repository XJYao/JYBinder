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
//考虑统一用一个nsset强引用关联node，各个node下用hashtable弱引用关联node


@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *name2Label;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.nameTextField setDelegate:self];
    
    self.person = [[Person alloc] init];
 
//    [JYBinder bindWithObjectsAndKeyPaths:
//     self.person, @"name",
//     self.nameLabel, @"text",
//     nil];
    
//    [JYBinder bindWithObjectsAndKeyPaths:
//     self.person, @"name",
//     self.name2Label, @"text",
//     nil];
    
    [JYBinder bindSourceObject:self.person sourceKeyPath:@"name" toObjectsAndKeyPaths:
     self.nameLabel, @"text",
     self.name2Label, @"text",
     nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (IBAction)drop:(id)sender {
    [self.person setName:@"tom"];
}
- (IBAction)drop2:(id)sender {
    [self.nameLabel setText:@"nick"];
    NSLog(@"person name = %@", self.person.name);
}

@end
