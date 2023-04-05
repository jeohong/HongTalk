//
//  SignupViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/04.
//

#import "SignupViewController.h"
#import "RegExOfTextfield.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseStorage;

@interface SignupViewController ()
/// Firebase Database 에 회원 정보를 저장하는 함수
-(void)setupDatabase: (FIRStorageReference *) imageRef  uid: (NSString *) uid sender: (id) sender;

/// Error 코드에 따른 Alert창 띄워주는 함수
-(void)presentAlert: (NSError *) error;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 경고문 숨기기 & 계정 생성 버튼 비활성화
    [self labelsSetHidden];
    [self setupLoginButton];
    
    // textField 적합성 검사
    [_emailTextfield addTarget:self action:@selector(emailTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_passwordTextfield addTarget:self action:@selector(passwordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_checkPasswordTextfield addTarget:self action:@selector(checkPasswordTextfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_nameTextfield addTarget:self action:@selector(nameTextfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // imageView Setting ( 갤러리에서 사진 가져오기 )
    [_profileImage setUserInteractionEnabled: YES];
    UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(setupImage)];
    [_profileImage addGestureRecognizer: imageTapGesture];
    
    // 키보드 숨기기
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

-(void)labelsSetHidden {
    [_correctEmailLabel setHidden: YES];
    [_correctPasswordLabel setHidden: YES];
    [_correctNameLabel setHidden: YES];
    [_checkPasswordLabel setHidden: YES];
}

// TextField 변동값에 따라 조건 설정
-(void)emailTextFieldDidChange :(UITextField *) textField {
    if ([[RegExOfTextfield sharedInstance] checkEmail: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctEmailLabel setHidden: YES];
    } else {
        [_correctEmailLabel setHidden:NO];
    }
    [self setupLoginButton];
}

-(void)passwordTextFieldDidChange :(UITextField *) textField {
    if ([[RegExOfTextfield sharedInstance] checkPassword: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctPasswordLabel setHidden: YES];
    } else {
        [_correctPasswordLabel setHidden: NO];
    }
    [self setupLoginButton];
}

-(void)checkPasswordTextfieldDidChange: (UITextField *) textField {
    if ([[RegExOfTextfield sharedInstance] equalToPassword: _passwordTextfield.text checkPasswordText: textField.text] || [[textField text] isEqualToString:@""]) {
        [_checkPasswordLabel setHidden: YES];
    } else {
        [_checkPasswordLabel setHidden: NO];
    }
    [self setupLoginButton];
}

-(void)nameTextfieldDidChange: (UITextField *) textField {
    if ([[RegExOfTextfield sharedInstance] checkName: textField.text] || [[textField text] isEqualToString:@""]) {
        [_correctNameLabel setHidden: YES];
    } else {
        [_correctNameLabel setHidden: NO];
    }
    [self setupLoginButton];
}

-(void)setupLoginButton {
    if (([_correctEmailLabel isHidden] &&
         [_correctPasswordLabel isHidden] &&
         [_correctNameLabel isHidden] &&
         [_checkPasswordLabel isHidden]) && (![[_emailTextfield text] isEqualToString:@""] &&
                                             ![[_passwordTextfield text] isEqualToString:@""] &&
                                             ![[_checkPasswordTextfield text] isEqualToString:@""] &&
                                             ![[_nameTextfield text] isEqualToString:@""])) {
        
        [_signupButton setBackgroundColor: [UIColor blueColor]];
        [_signupButton setEnabled: YES];
    } else {
        [_signupButton setBackgroundColor: [UIColor grayColor]];
        [_signupButton setEnabled: NO];
    }
}


- (IBAction)pressedCancelButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)pressedSignupButton:(id)sender {
    // 회원가입 진행중 일때 버튼을 재클릭 하지 못하도록 설정
    [_signupButton setTitle: @"회원가입중" forState: UIControlStateNormal];
    [_signupButton setBackgroundColor: [UIColor grayColor]];
    [_signupButton setEnabled: NO];
    [_cancelButton setHidden: YES];
    
    [[FIRAuth auth] createUserWithEmail: [_emailTextfield text]
                               password: [_passwordTextfield text]
                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        
        if (error != nil) {
            [self presentAlert: error];
        } else {
            NSString *uid = [[authResult user] uid];
            
            FIRUserProfileChangeRequest *changRequest = [[[FIRAuth auth] currentUser] profileChangeRequest];
            [changRequest setDisplayName: self->_nameTextfield.text];
            [changRequest commitChangesWithCompletion: nil];
            
            FIRStorageReference *imageRef = [[[FIRStorage storage] reference] child: @"userImages"];
            if (![[self->_profileImage image] isSymbolImage]) {
                // 이미지 설정이 되어있는 상태인 경우
                NSData *image = UIImageJPEGRepresentation([self->_profileImage image], 0.1);
                imageRef = [imageRef child: uid];
                [imageRef putData: image metadata: nil completion:^(FIRStorageMetadata * _Nullable data, NSError * _Nullable error) {
                    [self setupDatabase: imageRef uid: uid sender: sender];
                }];
            } else {
                // 이미지 설정을 하지 않은 경우
                imageRef = [imageRef child: @"basicProfile.png"];
                [self setupDatabase: imageRef uid: uid sender: sender];
            }
        }
    }];
}

-(void)presentAlert:(NSError *)error {
    // Error Code 문서 : https://firebase.google.com/docs/reference/ios/firebaseauth/api/reference/Enums/FIRAuthErrorCode
    NSString *errorMessage = @"";
    switch([error code]) {
        case 17007:
            errorMessage = @"이미 가입된 이메일입니다.";
            break;
        case 17020:
            errorMessage = @"네트워크 상태를 확인해주세요.";
            break;
        case 17008:
            errorMessage = @"올바른 이메일 형식이 아닙니다.";
            break;
        default:
            errorMessage = @"다시 시도해 주세요";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"회원가입 실패"
                                                                   message: errorMessage
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self->_signupButton setTitle: @"계정 생성" forState: UIControlStateNormal];
        [self->_cancelButton setHidden: NO];
        [alert dismissViewControllerAnimated: YES completion:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setupDatabase:(FIRStorageReference *) imageRef uid:(NSString *)uid sender:(id)sender {
    [imageRef downloadURLWithCompletion:^(NSURL * _Nullable url, NSError * _Nullable error) {
        NSDictionary *values = @{@"userName" : self->_nameTextfield.text, @"profileImageUrl": [url absoluteString], @"uid": [[[FIRAuth auth] currentUser] uid]};
        [[[[[FIRDatabase database] reference] child: @"users"] child: uid] setValue: values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error == nil)
                // 회원가입 성공
                [self pressedCancelButton: sender];
            else {
                // 회원가입 실패시
                [self presentAlert: error];
            }
        }];
    }];
}

-(void)setupImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: (id)self];
    [picker setAllowsEditing: YES];
    
    [picker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController: picker animated: YES completion: nil];
}

// imagePicker 델리게이트
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [_profileImage setImage: image];
    [_profileImage setClipsToBounds: YES];
    
    [[_profileImage layer] setCornerRadius: _profileImage.frame.size.height / 2];
    [picker dismissViewControllerAnimated: YES completion:nil];
}

// 키보드 숨기기
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
