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

-(NSString *)getCurrentUid {
    if (self.currentUid == nil) {
        self.currentUid = [[[FIRAuth auth] currentUser] uid];
    }
    return self.currentUid;
}
@end
