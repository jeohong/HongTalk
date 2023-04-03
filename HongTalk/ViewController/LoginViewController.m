//
//  LoginViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pressedLoginButton:(id)sender {
    NSLog(@"로그인");
}

-(void)pressedSignupButton:(id)sender {
    NSLog(@"회원가입");
}

@end
