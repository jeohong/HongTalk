//
//  SignupViewController.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/04.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UILabel *correctEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *correctNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *correctPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *checkPasswordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *checkPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
- (IBAction)pressedSignupButton:(id)sender;
- (IBAction)pressedCancelButton:(id)sender;

// methods
/// 경고문구 초반에 숨기기
- (void)labelsSetHidden;
@end

NS_ASSUME_NONNULL_END
