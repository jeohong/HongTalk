//
//  UserModel.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
@property (nonatomic) NSString *profileImageUrl;
@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *comment;
@end

NS_ASSUME_NONNULL_END
