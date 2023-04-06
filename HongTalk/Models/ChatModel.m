//
//  ChatModel.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/06.
//

#import "ChatModel.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _uid = dictionary[@"uid"];
        _message = dictionary[@"message"];
        _timestamp = dictionary[@"timestamp"];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:_uid forKey:@"uid"];
    [dictionary setObject:_message forKey:@"message"];
    [dictionary setObject:_timestamp forKey:@"timestamp"];

    return dictionary;
}

@end

@implementation ChatModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary new];
        _comments = [NSMutableDictionary new];
        NSDictionary *usersDictionary = dictionary[@"users"];
        for (NSString *userId in usersDictionary) {
            NSNumber *boolNumber = usersDictionary[userId];
            [_users setObject:boolNumber forKey:userId];
        }
        NSDictionary *commentsDictionary = dictionary[@"comments"];
        for (NSString *commentId in commentsDictionary) {
            NSDictionary *commentDictionary = commentsDictionary[commentId];
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [_comments setObject:comment forKey:commentId];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSMutableDictionary *usersDictionary = [NSMutableDictionary new];
    for (NSString *userId in _users) {
        NSNumber *boolNumber = _users[userId];
        [usersDictionary setObject:boolNumber forKey:userId];
    }
    [dictionary setObject:usersDictionary forKey:@"users"];
    NSMutableDictionary *commentsDictionary = [NSMutableDictionary new];
    for (NSString *commentId in _comments) {
        Comment *comment = _comments[commentId];
        NSDictionary *commentDictionary = [comment dictionaryRepresentation];
        [commentsDictionary setObject:commentDictionary forKey:commentId];
    }
    [dictionary setObject:commentsDictionary forKey:@"comments"];
    return dictionary;
}

@end
