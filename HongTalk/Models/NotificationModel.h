//
//  NotificationModel.h
//  HongTalk
//
//  Created by Hong jeongmin on 2023/04/10.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface Notification : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;

@end

@interface Data : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;

@end

@interface NotificationModel : NSObject

@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) Data *data;

- (NSDictionary *)dictionaryRepresentation;
@end
NS_ASSUME_NONNULL_END
