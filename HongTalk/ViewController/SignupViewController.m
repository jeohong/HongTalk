//
//  SignupViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/04.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)pressedCancelButton:(id)sender {
}

- (IBAction)pressedSignupButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}
@end
