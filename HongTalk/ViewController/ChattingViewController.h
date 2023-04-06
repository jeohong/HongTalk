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
@property (weak, nonatomic) IBOutlet UITableView *chattingTableView;

@property (nonatomic) NSString *destinationUid;

@end

// MARK: TableView Cell [ MyMessageCell ] Class
@interface MyMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *readCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@end

// MARK: TableView Cell [ DestinationMessageCell ] Class
@interface DestinationMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *readCountLabel;

@end
NS_ASSUME_NONNULL_END
