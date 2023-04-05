//
//  ChattingViewController.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChattingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

NS_ASSUME_NONNULL_END
