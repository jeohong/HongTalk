//
//  FirebaseManager.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/12.
//

#import <Foundation/Foundation.h>
@import FirebaseAuth;

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseManager : NSObject
// 싱글톤
+(instancetype) sharedInstance;

// Method
// MARK: Firebase Auth 관련 메소드
-(NSString *)getCurrentUid;
-(NSString *)getCurrentDisplayName;
-(void)setupUserToken;
-(void)signout;
-(FIRUserProfileChangeRequest *)getUserProfile;
-(void)resetUserData;
-(void)userChangeListener: (UIViewController *)viewController;
-(void)loginEmail:(NSString *)email password:(NSString *)password completeBlock: (void (^)(NSError *error, FIRAuthDataResult *result)) completeBlock;
-(void)signupEmail:(NSString *)email password:(NSString *)password completeBlock: (void (^)(NSError *error, FIRAuthDataResult *result)) completeBlock;

// MARK: Firebase Database 관련 메소드
// property

@end

NS_ASSUME_NONNULL_END
