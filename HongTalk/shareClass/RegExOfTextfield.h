//
//  RegExOfTextfield.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/04.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegExOfTextfield : NSObject
// singleton
+ (instancetype) sharedInstance;

// Methods
- (BOOL)checkEmail: (NSString *) emailText;
- (BOOL)checkPassword:(NSString *) passwordText;

@end

NS_ASSUME_NONNULL_END
