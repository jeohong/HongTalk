//
//  LoginViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/03.
//

#import "LoginViewController.h"
@import FirebaseAuth;

@interface LoginViewController ()
// Method
-(void)setupLoginButton;
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
    [[FIRAuth auth] signInWithEmail:[_emailTextfield text]
                           password:[_passwordTextfield text]
                         completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error != nil) {
            // Login 성공
            NSLog(@"로그인 실패 %@", [error localizedDescription]);
        } else {
            // 로그인 실패시 대응
            NSLog(@"로그인 성공");
        }
    }];
}

-(void)pressedSignupButton:(id)sender {
    NSLog(@"회원가입");
}

-(void)emailTextFieldDidChange :(UITextField *) textField {
    // 텍스트 필드의 이메일 형식 확인 || 텍스트 필드가 비어있을경우 경고표시 x
    if ([self checkEmail: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctEmailLabel setHidden: YES];
    } else {
        [_correctEmailLabel setHidden:NO];
    }
    [self setupLoginButton];
}

-(void)passwordTextFieldDidChange :(UITextField *) textField {
    // 텍스트 필드의 패스워드 형식 확인 || 텍스트 필드가 비어있을경우 경고표시 x
    if ([self checkPassword: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctPasswordLabel setHidden: YES];
    } else {
        [_correctPasswordLabel setHidden: NO];
    }
    [self setupLoginButton];
}

-(BOOL)checkEmail:(NSString *) emailText {
    const char *tmp = [emailText cStringUsingEncoding:NSUTF8StringEncoding];
    if (emailText.length != strlen(tmp)) {
        return NO;
    }
    
    NSString *check = @"([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\\.[0-9a-zA-Z_-]+){1,2}";
    
    NSRange match = [emailText rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location) {
        return NO;
    }
    
    return YES;
}

-(BOOL)checkPassword:(NSString *) passwordText {
    NSString *check = @"^(?=.*[a-zA-Z])(?=.*[^a-zA-Z0-9])(?=.*[0-9]).{6,20}$";
    NSRange match = [passwordText rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location) {
        return NO;
    }
    return YES;
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
