//
//  ChattingViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "ChattingViewController.h"

@interface ChattingViewController ()

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_messageTextView setClipsToBounds: YES];
    [[_messageTextView layer] setCornerRadius: 10];
    [[_messageTextView layer] setBorderWidth: 2];
}

@end
