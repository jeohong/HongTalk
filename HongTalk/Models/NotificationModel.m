//
//  NotificationModel.m
//  HongTalk
//
//  Created by Hong jeongmin on 2023/04/10.
//

#import "NotificationModel.h"

@implementation NotificationModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _notification = [[Notification alloc] init];
        _data = [[Data alloc] init];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (_to) {
        [dictionary setObject:_to forKey:@"to"];
    }
    if (_notification.title || _notification.body) {
        NSMutableDictionary *notificationDict = [NSMutableDictionary dictionary];
        if (_notification.title) {
            [notificationDict setObject:_notification.title forKey:@"title"];
        }
        if (_notification.body) {
            [notificationDict setObject:_notification.body forKey:@"body"];
        }
        [dictionary setObject:notificationDict forKey:@"notification"];
    }
    if (_data.title || _data.body) {
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        if (_data.title) {
            [dataDict setObject:_data.title forKey:@"title"];
        }
        if (_data.body) {
            [dataDict setObject:_data.body forKey:@"body"];
        }
        [dictionary setObject:dataDict forKey:@"data"];
    }
    return dictionary;
}

@end


@implementation Notification

@end


@implementation Data

@end
