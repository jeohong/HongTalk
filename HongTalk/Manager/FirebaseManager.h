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
-(NSString *)getCurrentUid;
-(NSString *)getCurrentDisplayName;
-(void)setupUserToken;
-(void)signout;
-(FIRUserProfileChangeRequest *)getUserProfile;
-(BOOL)isLogin;

// property
@property (nullable, nonatomic) NSString *currentUid;

@end

NS_ASSUME_NONNULL_END
