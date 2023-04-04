//
//  RegExOfTextfield.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/04.
//

#import "RegExOfTextfield.h"

@implementation RegExOfTextfield
+(instancetype)sharedInstance {
    static RegExOfTextfield *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[RegExOfTextfield alloc] init];
    });
    
    return shared;
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

@end
