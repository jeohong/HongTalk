//
//  LoginViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "LoginViewController.h"
#import "ChattingViewController.h"
#import "RegExOfTextfield.h"
@import FirebaseAuth;

@interface LoginViewController ()
// Method
-(void)setupLoginButton;

// 임시 버튼
- (IBAction)moveToView:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 이메일과 패스워드가 올바른지 확인하는 문구 처음에 숨기기
    [_correctEmailLabel setHidden: YES];
    [_correctPasswordLabel setHidden: YES];
    
    // 초기 버튼 비활성화
    [_loginButton setEnabled: NO];
    [_loginButton setBackgroundColor: [UIColor grayColor]];
    
    // email 과 password 올바른지 검사
    [_emailTextfield addTarget:self action:@selector(emailTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_passwordTextfield addTarget:self action:@selector(passwordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 텍스트 필드 외부 터치시 키보드 내리기
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [[self emailTextfield] setDelegate: (id)self];
    [[self passwordTextfield] setDelegate: (id)self];
}

- (void)pressedLoginButton:(id)sender {
    // 로그인 중일때 로그인 버튼 클릭 못하도록 설정
    [_loginButton setTitle: @"로그인중.." forState: UIControlStateNormal];
    [_loginButton setBackgroundColor: [UIColor grayColor]];
    [_loginButton setEnabled: NO];
    [_signupButton setHidden: YES];
    
    [[FIRAuth auth] signInWithEmail:[_emailTextfield text]
                           password:[_passwordTextfield text]
                         completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        
        NSString *errorMessage = @"";
        if (error != nil) {
            // 비밀번호 틀릴때 : 17009 , 아이디 틀릴때 : 17011, 계정 사용 중지 17005
            switch([error code]) {
                case 17009:
                    errorMessage = @"비밀번호를 확인해 주세요.";
                    break;
                case 17011:
                    errorMessage = @"해당 이메일을 찾을 수 없습니다.\n회원이 아니라면 회원가입을 진행해 주세요.";
                    break;
                case 17005:
                    errorMessage = @"해당 계정은 사용이 중지되었습니다.\n관리자에게 문의하세요.";
                    break;
                case 17020:
                    errorMessage = @"네트워크 상태를 확인해주세요.";
                    break;
                default:
                    errorMessage = @"다시 시도해 주세요";
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"로그인 실패"
                                                                           message: errorMessage
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self->_loginButton setTitle: @"로그인" forState: UIControlStateNormal];
                [self->_signupButton setHidden: NO];
                [alert dismissViewControllerAnimated: YES completion:nil];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // 로그인 성공 뷰 전환
            [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
                if (user != nil) {
                    UIStoryboard *tabbarSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    UITabBarController *tabbarVC = (UITabBarController *)[tabbarSB instantiateViewControllerWithIdentifier:@"MainViewTabBarController"];
                    tabbarVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:tabbarVC animated: NO completion:nil];
                }
            }];
        }
    }];
}

// MARK: 임시 테스트 계정
- (IBAction)tempButton2:(id)sender {
    [_emailTextfield setText: @"test2@test.com"];
    [_passwordTextfield setText: @"test123!"];
    [self setupLoginButton];
}

- (IBAction)tempButton:(id)sender {
    [_emailTextfield setText: @"test@test.com"];
    [_passwordTextfield setText: @"test123!"];
    [self setupLoginButton];
}

-(void)pressedSignupButton:(id)sender {
    UIStoryboard *signupSB = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:nil];
    LoginViewController *signupVC = (LoginViewController *)[signupSB instantiateViewControllerWithIdentifier:@"SignupViewController"];
    signupVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:signupVC animated: YES completion:nil];
}

-(void)emailTextFieldDidChange :(UITextField *) textField {
    // 텍스트 필드의 이메일 형식 확인 || 텍스트 필드가 비어있을경우 경고표시 x
    if ([[RegExOfTextfield sharedInstance] checkEmail: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctEmailLabel setHidden: YES];
    } else {
        [_correctEmailLabel setHidden:NO];
    }
    [self setupLoginButton];
}

-(void)passwordTextFieldDidChange :(UITextField *) textField {
    // 텍스트 필드의 패스워드 형식 확인 || 텍스트 필드가 비어있을경우 경고표시 x
    if ([[RegExOfTextfield sharedInstance] checkPassword: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctPasswordLabel setHidden: YES];
    } else {
        [_correctPasswordLabel setHidden: NO];
    }
    [self setupLoginButton];
}

-(void)setupLoginButton {
    // 경고문구가 둘다 없거나 , 둘다 비어있지 않을 경우에만 버튼 활성화
    if (([_correctEmailLabel isHidden] && [_correctPasswordLabel isHidden]) &&
        (![[_emailTextfield text] isEqualToString:@""] && ![[_passwordTextfield text] isEqualToString:@""])) {
        [_loginButton setBackgroundColor: [UIColor blueColor]];
        [_loginButton setEnabled: YES];
    } else {
        [_loginButton setBackgroundColor: [UIColor grayColor]];
        [_loginButton setEnabled: NO];
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
