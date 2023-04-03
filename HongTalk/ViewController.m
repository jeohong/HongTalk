//
//  ViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "ViewController.h"
#import "LoginViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 런치스크린 이후 로그인뷰 이동
    // 해결 내용 : 해당 뷰를 띄울때는 viewDidLoad 가 아닌 DidAppear 에서 띄워줘야 한다
    
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:nil];
    LoginViewController *loginVC = (LoginViewController *)[loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated: NO completion:nil];
}

@end
