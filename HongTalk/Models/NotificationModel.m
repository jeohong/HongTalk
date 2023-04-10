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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _to = [dictionary objectForKey:@"to"];
        
        NSDictionary *notificationDict = [dictionary objectForKey:@"notification"];
        if (notificationDict) {
            _notification.title = [notificationDict objectForKey:@"title"];
            _notification.text = [notificationDict objectForKey:@"text"];
        }
        
        NSDictionary *dataDict = [dictionary objectForKey:@"data"];
        if (dataDict) {
            _data.title = [dataDict objectForKey:@"title"];
            _data.text = [dataDict objectForKey:@"text"];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (_to) {
        [dictionary setObject:_to forKey:@"to"];
    }
    if (_notification.title || _notification.text) {
        NSMutableDictionary *notificationDict = [NSMutableDictionary dictionary];
        if (_notification.title) {
            [notificationDict setObject:_notification.title forKey:@"title"];
        }
        if (_notification.text) {
            [notificationDict setObject:_notification.text forKey:@"text"];
        }
        [dictionary setObject:notificationDict forKey:@"notification"];
    }
    if (_data.title || _data.text) {
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        if (_data.title) {
            [dataDict setObject:_data.title forKey:@"title"];
        }
        if (_data.text) {
            [dataDict setObject:_data.text forKey:@"text"];
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
