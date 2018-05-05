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

@interface ViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UITextView *textView2;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet UILabel *label3A;
@property (weak, nonatomic) IBOutlet UILabel *label3B;
@property (nonatomic, strong) Person *person3;

@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UITextField *textField4;
@property (nonatomic, strong) Person *person4;

@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (nonatomic, strong) Person *person5;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView2.delegate = self;
    self.textView2.layer.borderWidth = 1;
    
    //1
    JYBindToSingleWay(self.label1, text) = JYBindToSingleWay(self.textField1, text);
    
    //2
    JYBindToSingleWay(self.label2, text) = JYBindToSingleWay(self.textView2, text);
    
    //3
    self.person3 = [[Person alloc] init];
    
    JYBindToSingleWay(self.label3A, text) = JYBindToSingleWay(self.person3, name);
    JYBindToSingleWay(self.label3B, text) = JYBindToSingleWay(self.label3A, text);
    
    //4
    self.person4 = [[Person alloc] init];
    JYBindToSingleWay(self.label4, text) = JYBindToSingleWay(self.person4, name);
    
    JYBindToTwoWay(self.person4, name) = JYBindToTwoWay(self.textField4, text);
    
    //5
    self.person5 = [[Person alloc] init];
    JYBinderTerminal *labelTerminal = JYBindToSingleWay(self.label5, text);
    labelTerminal.map = ^id _Nullable(id  _Nullable value) {
        return [value boolValue] ? @"开" : @"关";
    };
    
    JYBinderTerminal *enableTerminal = JYBindToSingleWay(self.person5, enable);
    [JYBinder bindToSingleWayWithLeading:enableTerminal following:labelTerminal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)button3click:(id)sender {
    int num = [self.person3.name intValue];
    num ++;
    self.person3.name = @(num).stringValue;
}

- (IBAction)button4click:(id)sender {
    self.person4.name = @"点击啦";
}

- (IBAction)unbind1:(id)sender {
    JYUnbind(self.textField1, text, self.label1, text);
}

- (IBAction)unbind3:(id)sender {
    [JYBinder unbindWithTarget1:self.person3 keyPath1:@"name" target2:self.label3A keyPath2:@"text"];
    JYUnbind(self.label3A, text, self.label3B, text);
}

- (IBAction)unbind4:(id)sender {
    JYBinderTerminal *person4Terminal = [[JYBinderTerminal alloc] initWithTarget:self.person4 keyPath:@"name"];
    JYBinderTerminal *textField4Terminal = [[JYBinderTerminal alloc] initWithTarget:self.textField4 keyPath:@"text"];
    [JYBinder unbindWithOneTerminal:person4Terminal otherTerminal:textField4Terminal];
}

- (IBAction)enableClick:(id)sender {
    self.person5.enable = !self.person5.enable;
}

- (void)textViewDidChange:(UITextView *)textView {
    textView.text = textView.text;
}

@end
