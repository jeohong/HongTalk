//
//  ViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "HongTalk-Swift.h"
//#import "EditProfileViewController.h"

@import FirebaseAuth;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(widgetOn) name:@"widgetOn" object:nil];
}

- (void)widgetOn {
    NSLog(@"test3");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditProfileViewController *EditProfileVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [self.presentedViewController presentViewController:EditProfileVC animated: YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"test2");
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"test");
    
    // 런치스크린 이후 로그인뷰 이동
    // 해결 내용 : 해당 뷰를 띄울때는 viewDidLoad 가 아닌 DidAppear 에서 띄워줘야 한다
    if ([[[FIRAuth auth] currentUser] uid] == nil) {
        UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:nil];
        LoginViewController *loginVC = (LoginViewController *)[loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loginVC animated: NO completion:nil];
    }
    else {
        UIStoryboard *tabbarSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabbarVC = (UITabBarController *)[tabbarSB instantiateViewControllerWithIdentifier:@"MainViewTabBarController"];
        tabbarVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:tabbarVC animated: NO completion:nil];
    }
}

@end
