//
//  ChattingViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "ChattingViewController.h"

@interface ChattingViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textviewHeight;

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [_messageTextView setDelegate: self];
    [[_messageTextView layer] setCornerRadius: 10];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = CGSizeMake(textView.frame.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:size];
    CGFloat newHeight = MAX(newSize.height, 30);
    if ( (newSize.height / textView.font.lineHeight) >= 5) {
        self.textviewHeight.constant = 5 * textView.font.lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom;
    } else {
        self.textviewHeight.constant = newHeight;
    }
    [self.view layoutIfNeeded];
}

@end
