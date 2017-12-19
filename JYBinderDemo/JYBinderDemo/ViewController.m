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
#import <JYBinder/JYBinderProxy.h>
#import "aaaaa.h"
#import <objc/runtime.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *name2Label;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic, strong) Person *person;
//@property (nonatomic, strong) aaaaa *aaa;

//@property (nonatomic, strong) JYBinder *binder;

@end

@implementation ViewController {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.nameTextField setDelegate:self];
    
    self.person = [[Person alloc] init];
    
//    self.binder = [[JYBinder alloc] init];
//    [self.binder bindObject1:self.person property1:@"name" toObject2:self.nameLabel property2:@"text"];
    
//    dispatch_async(dispatch_queue_create("ddfd", DISPATCH_QUEUE_CONCURRENT), ^{
//
//    });
    
//    [JYBinder bindWithObjectsAndKeyPaths:
//     self.person, @"name",
//     self.nameLabel, @"text",
//     self.name2Label, @"text",
//     nil];
//    [self setAutomaticallyAdjustsScrollViewInsets:YES];
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
//    [textField resignFirstResponder];
//
////    [self.nameTextField setText:textField.text];
//    [self.person setName:textField.text];
//    [self.nameLabel setText:textField.text];
//    [self.person setHeight:4.6];
//    [self.person setAge:64];
//    [self.person setColor:[UIColor redColor]];
    return YES;
}

- (IBAction)drop:(id)sender {
//    self.person = nil;
//    [[JYBinderProxy sharedInstance] dsfdsf];
    [self.person setName:@"tom"];
}
- (IBAction)drop2:(id)sender {
    [self.nameLabel setText:@"nick"];
    NSLog(@"person name = %@", self.person.name);
}

@end
