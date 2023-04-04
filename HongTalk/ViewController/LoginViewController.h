//
//  LoginViewController.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController
// properties
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UILabel *correctEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *correctPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

// Actions
- (IBAction)pressedLoginButton:(id)sender;
- (IBAction)pressedSignupButton:(id)sender;

@end

NS_ASSUME_NONNULL_END
