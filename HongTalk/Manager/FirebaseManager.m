//
//  FirebaseManager.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/12.
//

@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseMessaging;
@import FirebaseStorage;

@interface FirebaseManager ()

@property (nullable, nonatomic) NSString *currentUid;

@end

@implementation FirebaseManager
// singleton
+(instancetype)sharedInstance {
    static FirebaseManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FirebaseManager alloc] init];
    });
    
    return shared;
}

// MARK: FirebaseAuth
-(NSString *)getCurrentUid {
    if (self.currentUid == nil) {
        self.currentUid = [[[FIRAuth auth] currentUser] uid];
    }
    return self.currentUid;
}

-(void)setupUserToken {
    if (self.currentUid == nil) {
        [self getCurrentUid];
    }
    [[FIRMessaging messaging] tokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error == nil) {
            [[[[[FIRDatabase database] reference] child: @"users"] child: self.currentUid] updateChildValues:@{@"pushToken": token}];
        }
    }];
}

-(NSString *)getCurrentDisplayName {
    return [FIRAuth auth].currentUser.displayName;
}

-(void)signout {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    
    [self resetUserData];
}

-(FIRUserProfileChangeRequest *)getUserProfile {
    return [[[FIRAuth auth] currentUser] profileChangeRequest];
}

-(void)resetUserData {
    FIRDatabaseReference *tokenRef = [[[[[FIRDatabase database] reference] child: @"users"] child: self.currentUid] child: @"pushToken"];
    [tokenRef removeValue];
    
    self.currentUid = nil;
}

-(void)userChangeListener:(UIViewController *)viewController {
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user != nil) {
            [viewController dismissViewControllerAnimated: YES completion:nil];
            
            [self setupUserToken];
        }
    }];
}

-(void)loginEmail:(NSString *)email password:(NSString *)password completeBlock: (void (^)(NSError *error, FIRAuthDataResult *result)) completeBlock {
    [[FIRAuth auth] signInWithEmail: email password: password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        completeBlock(error, authResult);
    }];
}

-(void)signupEmail:(NSString *)email password:(NSString *)password completeBlock: (void (^)(NSError *error, FIRAuthDataResult *result)) completeBlock {
    [[FIRAuth auth] createUserWithEmail: email password: password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        completeBlock(error, authResult);
    }];
}

// MARK: Firebase Database
-(void)setupDatabaseWithUid: (NSString *)uid setValue: (NSDictionary *) values completeBlock: (void (^)(NSError *error)) completeBlock {
    [[[[[FIRDatabase database] reference] child: @"users"] child: uid] setValue: values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        completeBlock(error);
    }];
}
@end
