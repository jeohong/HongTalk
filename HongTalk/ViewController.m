//
//  ViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "SceneDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SceneDelegate *sceneDelegate = (SceneDelegate *) [[[[[UIApplication sharedApplication] connectedScenes] allObjects] firstObject] delegate];
    sceneDelegate.naviVC = self.navigationController;
    
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 런치스크린 이후 로그인뷰 이동
    // 해결 내용 : 해당 뷰를 띄울때는 viewDidLoad 가 아닌 DidAppear 에서 띄워줘야 한다
    if (FirebaseManager.sharedInstance.getCurrentUid != nil) {
        UIStoryboard *tabbarSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabbarVC = (UITabBarController *)[tabbarSB instantiateViewControllerWithIdentifier:@"MainViewTabBarController"];
        tabbarVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:tabbarVC animated: NO];
    }
    else {
        UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:nil];
        LoginViewController *loginVC = (LoginViewController *)[loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loginVC animated: NO completion:nil];
    }
}

@end
