//
//  ChatModel.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/06.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSNumber *timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end

@interface ChatModel : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *users;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Comment *> *comments;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END

/*
 
 */
