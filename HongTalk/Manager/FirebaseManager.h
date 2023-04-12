//
//  FirebaseManager.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseManager : NSObject
// 싱글톤
+(instancetype) sharedInstance;

// Method
-(NSString *)getCurrentUid;

// property
@property (nullable) NSString *currentUid;

@end

NS_ASSUME_NONNULL_END
