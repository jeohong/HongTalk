//
//  NSDateFormatter+Custom.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

#import "NSNumber+DayTime.h"

@implementation NSNumber (DayTime)

- (NSString *)toDayTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]/1000.0];
    return [dateFormatter stringFromDate:date];
}

@end
